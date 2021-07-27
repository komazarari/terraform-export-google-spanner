variable "project_id" {
  type = string
}
variable "spanner_instance" {
  type = string
}
variable "spanner_db" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "region" {
  type    = string
  default = "asia-northeast1"
}
variable "export_schedule" {
  type    = string
  default = "0 0 * * *"
}
variable "days_buckups" {
  type    = number
  default = 7
}
variable "dataflow_template_version" {
  type    = string
  default = "2021-07-05-00_RC01"
}
