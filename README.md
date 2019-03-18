# PGRE
Scripts for PGRE@FEUP

The following scripts are meant to configure a prototype production network with:
* Web server
* FTP/sFTP server
* NTP server
* e-mail server
* DNS server

### Computers
| Name                  | IP          | Services                   |
|:---------------------:|-------------|:--------------------------:|
| tux61, ftp, ns1, mail | 172.16.1.61 | Web, FTP, NTP, e-mail, NS1 |
| tux62, ns2            | 172.16.1.62 | NS2                        |
| tux63                 | 172.16.1.63 | (client)                   |
| tux64                 | 172.16.1.64 | (client)                   |

For simplicity, most of the services will be provided by the same server, so that we have a single machine to configure.\
The configuration is done by running `./tux6X.sh` on the corresponding machine.
