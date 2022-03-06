resource "cloudamqp_instance" "lostcities_events_queue" {
  name          = "lostcities_events_${var.env}"
  plan          = "lemur"
  region        = "amazon-web-services::us-east-1"
  nodes         = 1
  tags          = [ "terraform" ]
  rmq_version   = "3.8.3"
}
