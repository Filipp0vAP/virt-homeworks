resource "yandex_compute_image" "ubuntu-image" {
  name       = "latest_ubuntu_image"
  source_image = "fd89jk9j9vifp28uprop"
}

resource "yandex_compute_instance" "vm" {
  name = "vm-from-custom-image"

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