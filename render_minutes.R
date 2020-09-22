library(rmarkdown)
library(dplyr)
library(purrr)

input_dir <- "markdown_notes"
input_pattern <- "^minutes.+\\.md$"

output_dir <- "formatted_output"
output_pattern <- ".+(\\d{4}-\\d{2}-\\d{2}).+"
output_replace <- "RDMinutes_\\1.docx"

RMD_template <- "minutes_template.Rmd"

#### define input and output files
minutes_df <- data.frame(in_files = list.files(input_dir, 
                                               pattern = input_pattern)) %>%
  mutate(in_path = file.path(input_dir, in_files), 
         in_time = file.mtime(in_path), 
         out_files = sub(output_pattern, output_replace, in_files), 
         out_full_path = file.path(output_dir, out_files), 
         out_exists = file.exists(out_full_path), 
         out_time = file.mtime(out_full_path), 
         needs_updating = in_time > out_time, 
         needs_rebuild = !out_exists | !is.na(out_time) & needs_updating)

#### loop over and rebuild necessary RMD output
if (any(minutes_df$needs_rebuild))
{
  minutes_df %>%
    filter(needs_rebuild) %>%
    rowwise() %>%
    mutate(rmd_out = rmarkdown::render(RMD_template, 
                                       output_file = out_files, 
                                       output_dir = output_dir, 
                                       params = list(file_in = in_files))
    )
} else {
  message("All files are up to date.")
}