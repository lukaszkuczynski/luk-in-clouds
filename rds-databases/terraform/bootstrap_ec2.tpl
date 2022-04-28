#cloud-config
# Add groups to the system
# Adds the ubuntu group with members 'root' and 'sys'
# and the empty group hashicorp.
groups:
  - ubuntu: [root,sys]
  - hashicorp

# Add users to the system. Users are added after groups are added.
users:
  - default
  - name: terraform
    gecos: terraform
    shell: /bin/bash
    primary_group: hashicorp
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMMHTxwuskfkl+L9emCVaY7YsIJR/u/CuCPSe7kSLxp7eZHYNNBWMBeQeUWiVPA3sJy1p6DwgKYhpMUF05wL8jig9vJDssGGzLFkM8LyAivkR2BpZETXDFzIInBoQwbmiqqCII2Hg4ymHgGeTVJz8NNZIzICQdT1/71JsvBVRXPKlJkgHqSNe9/Sd2iW+ZwD9B1jI5zFb+vEisAsoEYLwKASW2/b9biQOY5A9qT07gaF1eJwjJ2RmyoMAq49FAJS7Pd3axXYZgXNSeKOYZ0xo7iTXH+3NRx9C2D7FQGmqxxQIT2ydi3Y32RNwQaeC7xX99rzk97uFk4Y/8SQq9akaDdWbFKW+GqSaitMgrHKURmaSSYH++EqI4bBgBRVKM3Ae+MsoVZN/LD2UZQF2DcGSZxwPVHcjZfcFow7JCT7g09c8HJVbvDmk4uiGGgNSoJw/qlx94dKq9ih9euGfGfPfdBI00bvO+QofjKETENpz7SDG3amUx73BQc6+C18MFFeM= luk@MacBook-Pro

packages:
  - golang-go
  - httpd
  - mysql
