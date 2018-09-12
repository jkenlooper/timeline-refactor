# API for timeline

The timeline-api.service should be placed in /etc/systemd/system/ in order to function. Note that this is commonly done by the install script.

```
sudo cp timeline-api.service /etc/systemd/system/
```

Start and enable the service.

```
sudo systemctl start timeline-api
sudo systemctl enable timeline-api
```

Stop the service.

```
sudo systemctl stop timeline-api
```

View the end of log.

```
sudo journalctl --pager-end _SYSTEMD_UNIT=timeline-api.service
```

Follow the log.

```
sudo journalctl --follow _SYSTEMD_UNIT=timeline-api.service
```

View details about service.

```
sudo systemctl show timeline-api
```

Check the status of the service.

```
sudo systemctl status timeline-api.service
```

Reload if timeline-api.service file has changed.

```
sudo systemctl daemon-reload
```

