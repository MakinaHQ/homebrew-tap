# Requires Homebrew's internal utilities
require "utils/formatter"
require "utils/github"
require "json"

# This custom download strategy is required to download releases from a private GitHub repository.
# It uses the HOMEBREW_GITHUB_API_TOKEN environment variable for authentication.
class GithubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  # Set up owner, repo, and token on initialization
  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  # The regex pattern to match the standard GitHub release URL format.
  def parse_url_pattern
    # Matches: https://github.com/owner/repo/releases/download/tag/filename
    url_pattern = %r{https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    
    unless match = url.match(url_pattern)
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Private Release."
    end
    
    # Extract owner, repo, tag, and filename from the URL
    _, @owner, @repo, @tag, @filename = *match
  end

  # Check for and set the GitHub token from the environment variable.
  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    
    if @github_token.to_s.empty?
      raise CurlDownloadStrategyError, "HOMEBREW_GITHUB_API_TOKEN environment variable is required for private downloads."
    end
  end

  # --- API Calls and Download Logic ---

  # 1. Fetch release metadata by tag name using the authenticated token
  def fetch_release_metadata
    url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}"
    
    GitHub.open_api(url, @github_token) do |json|
      return JSON.parse(json)
    end
    
    # Fallback/error if metadata fetch fails
    raise CurlDownloadStrategyError, "Could not fetch release metadata for #{@owner}/#{@repo} with tag #{@tag}."
  end

  # 2. Get the specific asset ID from the metadata
  def asset_id
    # Fetch all assets for the release
    release_metadata = fetch_release_metadata
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    
    if assets.empty?
      raise CurlDownloadStrategyError, "Asset '#{@filename}' not found in release '#{@tag}'."
    end
    
    # The ID of the asset we want to download
    assets.first["id"]
  end

  # 3. Construct the final authenticated download URL (API endpoint)
  def download_url
    "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  # 4. Perform the download using the API URL and required headers
  def _fetch(url:, resolved_url:, timeout:)
    # Homebrew uses curl, so we provide the necessary headers for an authenticated API download.
    # The 'Accept' header is critical to signal that we want the binary file (octet-stream)
    # and not the default JSON metadata.
    curl_download download_url, 
                  "--header", "Accept: application/octet-stream", 
                  "--header", "Authorization: token #{@github_token}", 
                  to: temporary_path
  end
end
