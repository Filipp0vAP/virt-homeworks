resource "yandex_compute_image" "ubuntu-image" {
  name       = "latest_ubuntu_image"
  source_image = "fd89jk9j9vifp28uprop"
}

resource "yandex_compute_instance" "vm" {
  name = "vm-from-custom-image"
  count = local.instance_count[terraform.workspace]

  platform_id = local.platform_id[terraform.workspace]
  resources {
    cores  = 2
    memory = 4
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }
  # ...

  boot_disk {
    initialize_params {
      image_id = "${yandex_compute_image.ubuntu-image.id}"
    }
  }
}

resource "yandex_compute_instance" "vm-cycle" {
  for_each = local.instance_name
  name = each.value
  platform_id = each.key
  
  resources {
    cores  = 2
    memory = 4
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }
  
  boot_disk {
    initialize_params {
      image_id = "${yandex_compute_image.ubuntu-image.id}"
    }
  }
}


locals {
  instance_count = {
    stage = 1
    prod = 2
  }
  platform_id = {
    stage = "standard-v1"
    prod = "standard-v2"
  }
  instance_name ={
    standard-v1 = "stage"
    standard-v2 = "prod"
  }
}