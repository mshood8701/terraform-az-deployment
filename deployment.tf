
resource "null_resource" "pre_deployment" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
bash -c 'echo "Deployment started at $(date)" > deployment-${local.ts_file}.log'
EOT
  }
}

resource "null_resource" "post_deployment" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.pre_deployment]

  provisioner "local-exec" {
    command = <<EOT
bash -c 'echo "Deployment ended at $(date)" >> deployment-${local.ts_file}.log'
EOT
  }
}
