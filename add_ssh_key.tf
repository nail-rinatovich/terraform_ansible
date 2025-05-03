resource "yandex_compute_instance_group" "update_ssh_keys" {
  name = "update-ssh-keys"
  
  instance_template {
    metadata = {
      ssh-keys = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwPmoGEi5ipyBP1hMNAWcrbxk+op/7nLU1qJSq8s8Kdo4kVJzO/+PuNGuIW0RoM8dWXmyDsa1V6vQODJxX0DqFSANxTjXlsk738Nv8OJtZD/8tOnp3CKTAAgwoc3BXyxSnMi9EbReFWoncV1AgXSqM4m7yTnb+4rfNtHpME8uxKZFUnObFMiim49Enmfv9JrcFOhyoy5nqtsKP4MEHcIqqoi+oTMZPSWh4/R4j7wB7MwZn84NPZjUX5+y+QSbgNP6/I8QyCaV5IX0t0LPtuI+W/Q61NFtBqTeMGoY6tKN/ZvbvF6KvkADUwD0Xjm4FNxI42DM46o0lhxtsDrY4p7iWMgHn/4rWKcDmPguPvloiNDHtIjRFXcZq/QuP43uKJ4cQ0m3YNj0+LoD3BNN4DFp5ySWOLdXL7nmNDTwXo5d3kByQzpZZJUThOP+tnF7z3xZNcb9lzzjLdlykIY7PylnKG8lmcYJSx/tww3Qb9BgjdntsAaV6g8H9WkB440vNEvU= ubuntu@fhmbt3ej0en1u9mruegd"
    }
  }
} 