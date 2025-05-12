# rpi-webhooks

A very simple Flask-based API that allows the user to execute commands and scripts on a Raspberry Pi (or other Linux box) by making a web request to the device.

**Warning: This project was developed as a small utility for easily executing commands like reboot and shutdown on headless Raspberry Pi computers. It has not been tested extensively. Allowing network users to execute commands on a computer obviously represents a security concern. To sum up: Use this at your own risk!**

## First setup

To install, download this repository on the Pi and run `install.sh` with `sudo`. This achieves the following:

- Installs python dependencies, using apt
- Copies files to proper locations in the file system
  - API script: `/opt/rpi-webhooks/api.py`
  - Config file: `/etc/opt/rpi-webhooks/routes.yaml`
  - systemd unit file: `/etc/systemd/system/webhooks.service`
- Enables and starts the API as a systemd service
- Creates a log file from the installation at `/var/log/rpi-webhooks-install.log` for debugging

The API should now be running and working after reboots as well.

### Firewall configuration

If you have a firewall running on the Pi, allow incoming traffic on port 5000.

## Usage

To use the API, make a POST request to the Pi using this scheme: `<ip-address-of-your-Pi>:5000/<command>`

For instance, telling a Pi with the IP address `10.0.0.10` to shut down using curl:
`curl -x POST 10.0.0.10:5000/shutdown`

## Functionality

### Default commands

Two commands are enabled by default: `/shutdown` and `/reboot`.

```yaml title="/etc/opt/rpi-webhooks/routes.yaml"
routes:
  /shutdown:
    command: "sudo shutdown -h now"
    response_message: "Shutting down."
  /reboot:
    command: "sudo reboot now"
    response_message: "Rebooting."
```

### Custom commands

To define your own commands, modify `/etc/opt/rpi-webhooks/routes.yaml`, following the examples above. Note that commands must begin with a `/`, and the fields `command` and `response_message` are both mandatory.

```yaml title="/etc/opt/rpi-webhooks/routes.yaml"
routes:
  /my-script:
    command: "/home/pi/my-script.sh"
    response_message: "Running a cool script."
```

After editing `routes.yaml`, run `sudo systemctl restart webhooks.service` to let the Flask application pick up the changes.

## Management

The API can be managed with the usual tools for [managing services with systemd](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd#sect-Managing_Services_with_systemd-Services), i.e. `sudo systemctl stop webhooks.service` to stop the API, etc.

For debugging, logs can be studied with `journalctl --unit=webhooks.service`.

## Uninstalling

To uninstall, run `uninstall.sh`, which stops and disables the systemd service and deletes the installed files and the installation log.
