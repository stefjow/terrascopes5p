# terrascopes5p

R package for downloading Sentinel-5P Level 3 products from the [Terrascope STAC API](https://stac.terrascope.be/).

Supports arbitrary bounding boxes, date ranges, and collections (NO2, SO2, O3, etc.).

## Installation

```r
remotes::install_github("stefjow/terrascopes5p")
```

## Setup

Set your Terrascope credentials as environment variables (register at <https://terrascope.be/>):

```
TERRASCOPE_USER=your_username
TERRASCOPE_PASS=your_password
```

Add these to your `~/.Renviron` file, or set them in your session with `Sys.setenv()`.

## Usage

```r
library(terrascopes5p)

# Browse available collections
list_s5p_collections()

# Search without downloading
items = search_s5p(
  bbox = c(16.0, 48.0, 16.7, 48.4),
  start_date = "2026-01-01",
  end_date = "2026-03-01"
)

# Download NO2 data
result = download_s5p(
  bbox = c(16.0, 48.0, 16.7, 48.4),
  start_date = "2026-01-01",
  end_date = "2026-03-01",
  output_dir = "data/raw"
)
```

## Functions

| Function | Description |
|---|---|
| `terrascope_credentials()` | Read credentials from environment variables |
| `list_s5p_collections()` | List available Sentinel-5P collections |
| `search_s5p()` | Search STAC API for items matching bbox/dates |
| `download_s5p()` | Search and download NetCDF files |

## Collection selection

The `collection` parameter is required. In interactive R sessions, omitting it will present a picker menu. In scripts, you must specify it explicitly (e.g., `collection = "terrascope-s5p-l3-no2-td-v2"`).
