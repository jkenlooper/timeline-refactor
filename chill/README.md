# Chill app for timeline

The timeline-chill.service should be placed in /etc/systemd/system/ in order to function. Note that this is commonly done by the install script.

```
sudo cp timeline-chill.service /etc/systemd/system/
```

Start and enable the service.

```
sudo systemctl start timeline-chill
sudo systemctl enable timeline-chill
```

Stop the service.

```
sudo systemctl stop timeline-chill
```

View the end of log.

```
sudo journalctl --pager-end _SYSTEMD_UNIT=timeline-chill.service
```

Follow the log.

```
sudo journalctl --follow _SYSTEMD_UNIT=timeline-chill.service
```

View details about service.

```
sudo systemctl show timeline-chill
```

Check the status of the service.

```
sudo systemctl status timeline-chill.service
```

Reload if timeline-chill.service file has changed.

```
sudo systemctl daemon-reload
```
