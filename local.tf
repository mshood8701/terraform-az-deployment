locals {
  # Format timestamp for filename: replace characters not allowed in filenames
  ts_file = replace(replace(replace(timestamp(), ":", "-"), "T", "_"), "Z", "")
}
