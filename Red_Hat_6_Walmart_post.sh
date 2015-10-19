#!/usr/bin/env bash

# --Begin Red Hat Satellite command section--
cat > /tmp/gpg-key-1 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.0 (MingW32)

mQGiBEIxWpoRBADb06sJgnD7MJnm2Ny1nmTFLDSZ8vkubP+pmfn9N9TE26oit+KI
OnVTRVbSPl3F15wTjSBGR453MEfnzp1NrMk1GIa/m1nKAmgQ4t1714C4jQab0to+
gP51XhPhtAGt7BggorQw2RXa4KdTCh8ByOIaDKRYcESmMazSZ+Pscy2XRwCgm771
21RCM0RcG2dmHZZgKH8fTscD/RiY3CHI2jJl9WosIYXbZpOySzrLn0lRCRdNdpew
Y5m1f3lhqoSvJk7pXjs4U+3XlOlUhgWl5HiXuWSVyPu2ilfGdfgpJslawI85fBQg
Ul5kcrjLHHsApeG8oGStFJE2JAc+0D+whmGmJbjWKwuZJmgpm9INplA4h1BYJbx+
6A3MBACFiMTttDPpJ+5eWr1VSZwxCZNqvPWmjpL5Nh9F8xzE7q+ad2CFKSebvRrv
Jf7Y2m+wY9bmo5nJ3wHYEX3Aatt+QVF10G6wTdIz/Ohm/Pc4Li4NhzYOv7FKxVam
97UN0O8Rsl4GhE2eE8H+Q3QYFvknAWoTj3Rq3/A5FA6FsRFhxbQwSGV3bGV0dC1Q
YWNrYXJkIENvbXBhbnkgKEhQIENvZGVzaWduaW5nIFNlcnZpY2UpiGQEExECACQF
AkIxWpoCGwMFCRLMAwAGCwkIBwMCAxUCAwMWAgECHgECF4AACgkQUnvFOiaJuIc1
2wCgj2UotUgSegPHmcKdApY+4WFaz/QAnjI58l5bDD8eElBCErHVoq9uPMczuQIN
BEIxWqUQCADnBXqoU8QeZPEy38oI0GrN2q7nvS+4UBQeIRVy8x+cOqDRDcE8PHej
7NtxP698U0WFGK47GszjiV4WTnvexuJk0B5AMEBHana8fVj7uRUcmyYZqOZd7EXn
Q3Ivi8itfkTICkhZi7bmGsSF0iJ0eAI5n2bCqJykNQvJ6a3dWJKP8EgaBCZj+TGL
WWJHDZsrn8g4BeaNS/MbmsCLAk8N6bWMGzAKfgxUraMCwuZ9fVyHFavHdeChUtna
qnF4uw0hHLaGWmTJjziXVvVC1a8+inTxPZkVpAvD0A+/LNlkP7TtAdaVOJqv3+a3
ybMQL851bRTFyt+H0XGHhzhhtuu9+DyfAAMFCADRWGxIfniVG7O4wtwLD3sWzR/W
LmFlJYu4s9rSDgn3NDjigQzZoVtbuv3Z9IZxBMoYa50MuybuVDp55z/wmxvYoW2G
25kOFDKx/UmkKkUBLdokb5V1p9j5SJorGBSfsNAHflhmBhyuMP4CDISbBUSN7oO1
Oj41jNxpqhy+8ayygSVcTNwMe909J/HdC//xFANLDhjKPf3ZAulWNhOvjTlpF46B
yt1l8ZNinIeE7CFL7H+LlMl2Ml6wsOkrxsSauBis6nER4sYVqrMdzpUU2Sr2hj6Q
sJ+9TS+IURcnxL/M851KCwLhwZKdphQjT3mXXsoCx/l3rI6cxpwYgjiKiZhOiE8E
GBECAA8FAkIxWqUCGwwFCRLMAwAACgkQUnvFOiaJuIenewCdHcEvMxBYprqRjKUw
04EypyFtZTgAn0wds0nbpd2+VZ5WHbVRfU4y5Y5Y
=+cX+ 
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key1
rpm --import /tmp/gpg-key-1
cat > /tmp/gpg-key-2 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
=fdzz
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key2
rpm --import /tmp/gpg-key-2
cat > /tmp/gpg-key-3 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.13 (GNU/Linux)

mQENBFHMPZIBCADI1ChzSp9OFdwC2Mes394bTcEVLxftaGEqtNH7fI9kCHHk6q0h
MxEfGcVy57wlJQSelwWQpsa8TSXj2qQAUCsZxqcdhDyMVkHeU9HAjkaDcfbELp0R
t/iQYdocA8PoUD5fErPMOhuPfhTBInchmgmSzkF5y2JEe5TSyAX5g7TiSkfVxp/r
wke0tcl+LV/4JLiAX8RWusjSeoVrzmm/+EPk4v+q1m+bvzhahvew+buqbh17x27N
TYPqGUC9MPt20aj7u6NDUQkFRh06j0hcO3UuD0DWSR50o0s4lkCYW743051k7jrE
PhWxkZOArFtdcUx235PG7CNTWVEgxY0rDQUbABEBAAG0YVdhbG1hcnQgUlBNIFBh
Y2thZ2luZyBTaWduZXIgKElTRCBJbmZyYXN0cnVjdHVyZSBBdXRvbWF0aW9uIFRl
YW0pIDxJU0RJTkZSQTM4QGVtYWlsLndhbC1tYXJ0LmNvbT6JAT8EEwECACkFAlHM
PZICGwMFCQPCZwAHCwkIBwMCAQYVCAIJCgsEFgIDAQIeAQIXgAAKCRCNdS4iLauM
FwXmB/4xWHM14pBpFmnON0ECAC8GjcNjKz/2GdAJ1vPNx4qy6ZrqTP1X2CILei0L
xxdfYL0y9TyNGmsB8ajeSD4BogXrlDodeB6ur3+hHTR3lJJgDIAq3l7QTIHkPTWw
uDLzqZee3ukWgB4KPtWrgM4w9mZFF0kU6l7Dpu6TK9ZCxAyuXjAdrC/4vPmyDpyr
n+qIUH6vhiZjdSutQ9N1ilZpFmIfph9o5Dwn4q7H1EUQ5T+9QK58tWClfHpJlE5U
TVr18aN1tk/bGcnAoCAM8OxGphyt+6E+sB8E9xWcaRy4K+8Vy6gvJtPN33fJ79RM
6e2xiJq3V1EWUOH9+8AYXQ/VNlJLuQENBFHMPZIBCAC+YFpDdwScstIt8d9AZOAo
S33Ii/clSQqhZye4XyBHIwekIEzU5qqW8qhHSKkgRkKsvNaczPCXYWObrgwDFe+a
wiO4fJ2DakVEVqsKRmQpYcceSQI5UmMz8JPAMNXLswCmYEchJZgokydUf1brT85u
u5/70U4QeB8QYL9sIGCiw/mn3VOhNWjpG1PMw1GnKVw3UCRd3As/04M5dzB/Ajg4
B1bAA0Sj2E7KQW96HWCz+RnJKQ6jAZ+SyJkTqy+tWzW6V7WOfPT/15luByyq76BS
BvmCuzAfF+XXR+jRIqbi6/CzmUkVkEKV3/V/eS1AZ1m16A5zFuL+2h9P8ZQNrYzv
ABEBAAGJASUEGAECAA8FAlHMPZICGwwFCQPCZwAACgkQjXUuIi2rjBc4rwf+Ia7L
I1Rvnekg+VbOwLPD8eDol1CcrVYxWS+82rH8IHw7LYJRePLnYy8Y64XaZFB8PcYz
gy0h3YTOSUBUSRX0orLCguDxts29UMSW1CxhVoz4vTuDSb1ocbkK6bK0NilmcAY3
l1ordjgMu/k0s898qPrFoPyHti3tAPB3eSX3yYgoVF/bF2/tsSlW3ReDhfr4Zy4t
awx6RuqbmJWqu5Y8UJccysWxxUq+XWdVHOq9a5h4adCV1efSwKTKY8Lm9rreeShf
wPPoe8aHAnlLtur8lwU100XW/7Vj5t14axx/Achk4TGdOoT2wVU5hXw73ZOE6KAV
7xGcAL1Y1WAE99wO2A==
=xX/6
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key3
rpm --import /tmp/gpg-key-3
cat > /tmp/gpg-key-4 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.5 (GNU/Linux)

mQGiBE0BIjkRBACat0LEgBITw51eHoXZOxVfAhT5Q8s/LI29bz7AEj+WE64hlTul
3DECC0YmjcEPULxuZ5Wl/lycIgcPsHtie6vaXgRAr2GDmhJ3IM2QJrbGlH+k0EbH
NsoYI9jbxuGS2yUv3YhcotvyF62+A8oBdZPuyUGGAlW/5KQuWxpwS56trwCgsdC2
3HkXJFMCa42DFAYjfpg4rUMD/iUPL2tZiwGDhPMO833G70rICp/Cjz9SocW7FvFC
TtAaAc9t4n0QS1xoFf4h09gnkjS7oRg2PhQG0lx4M0HpdmYGf6g11bkHJ8bWt/f/
eO+nchTR1uj4mgSlgdvVUxfQIcU/5tpXfNYYwy2OScvBuE5dUs2DFHXDFhVud53S
p9laA/476yM1vORb3smnosuYjc928Ptu5z3XsFJDAXXqtUq/1jO6se83kfqvCy7S
JQKAi6PRoDJ1L6M3TSX1Fcynl8KvSTXd+xor+yf3mug8qWbyoMigMEKhYqoNnkcI
Eo5/4pz+9W+/3ZNK+lWdd7wQk7odJmaUWCe5DEze3fk6WAZGdbQoTmV0d29yayBB
dXRvbWF0aW9uIDxuZXRtZ3RAd2FsLW1hcnQuY29tPohgBBMRAgAgBQJNASI5AhsD
BgsJCAcDAgQVAggDBBYCAwECHgECF4AACgkQAG5fRh2qqiTMmACcCd7iiK33Ozqn
vsEhBcNtDcX28QUAn2Ocf1Ix+AMWUTN5Qpem8admmHMVuQINBE0BIj0QCACaVo5g
fNZadlclExWMQbFLCRLlK8T7Yeg93j1/9QO+JucwbKrIS5z69tek9IXz6mQURRfZ
IPqoGYjA3uYe3HKKB4jTesaxq2+SBH2wuponxntz2/wqpuPYhLs7wtaYItGfq1Tr
zSGTtogKSM54xkiDwoi/EkGcHHzxBnsa5uetLQ1xvUCMo5O2Nbup3Uhloa+xeyuf
eykJ6nRBjhF/xviVjf4aE5gdtglEyI+45W1nAU0579yb4/FPdPwS1ecjfH2MmCxQ
h8zODiUTzdz5GpYXI5L1gY0+FUfK25G9ZXqizGIuolrqLsWzPjAG/IwORQtSbobs
ajH8DeReV9rZr5JvAAMHCACE0Rs58ae3XV28yHAzWPLqt0cnPJL8L9qTQzOEdKhz
T50x2eha2n3xJrAAD0zimjvQwPnnH2XQGpndRAW2XTjZD2isxE1MdZqM2bynC5rI
Ar/mtdIYOvCDxrId4wOPikNFe3qZzDANGGEzU1ydyIDWhhB10rs2GGAEeG9vyL0K
p75ObDcI6jFk+qkuCvN8BJCREYV+8yHJMrMCIGdN+ErcxJwq3zsIFWvDIa27W+4F
4oHu+1reFnJyGPslQ1O/8qj+IkczB0pLQMeyLWNIQQlJg9FDJES1Jf39Bku3OQtU
7OFQk05IKoJc/VRzDTimZ1l9G8+KeykdCwazyDlfL09jiEkEGBECAAkFAk0BIj0C
GwwACgkQAG5fRh2qqiSCfwCgplZhALAD0yf/hcUTzO1lFSjRpCwAn3p62eVDaq+f
AZRgosHEI4rlqRLE
=/5oH
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key4
rpm --import /tmp/gpg-key-4
cat > /tmp/gpg-key-5 <<'EOF'
pub  4096R/0608B895 2010-04-23 EPEL (6) <epel@fedoraproject.org>

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.5 (GNU/Linux)

mQINBEvSKUIBEADLGnUj24ZVKW7liFN/JA5CgtzlNnKs7sBg7fVbNWryiE3URbn1
JXvrdwHtkKyY96/ifZ1Ld3lE2gOF61bGZ2CWwJNee76Sp9Z+isP8RQXbG5jwj/4B
M9HK7phktqFVJ8VbY2jfTjcfxRvGM8YBwXF8hx0CDZURAjvf1xRSQJ7iAo58qcHn
XtxOAvQmAbR9z6Q/h/D+Y/PhoIJp1OV4VNHCbCs9M7HUVBpgC53PDcTUQuwcgeY6
pQgo9eT1eLNSZVrJ5Bctivl1UcD6P6CIGkkeT2gNhqindRPngUXGXW7Qzoefe+fV
QqJSm7Tq2q9oqVZ46J964waCRItRySpuW5dxZO34WM6wsw2BP2MlACbH4l3luqtp
Xo3Bvfnk+HAFH3HcMuwdaulxv7zYKXCfNoSfgrpEfo2Ex4Im/I3WdtwME/Gbnwdq
3VJzgAxLVFhczDHwNkjmIdPAlNJ9/ixRjip4dgZtW8VcBCrNoL+LhDrIfjvnLdRu
vBHy9P3sCF7FZycaHlMWP6RiLtHnEMGcbZ8QpQHi2dReU1wyr9QgguGU+jqSXYar
1yEcsdRGasppNIZ8+Qawbm/a4doT10TEtPArhSoHlwbvqTDYjtfV92lC/2iwgO6g
YgG9XrO4V8dV39Ffm7oLFfvTbg5mv4Q/E6AWo/gkjmtxkculbyAvjFtYAQARAQAB
tCFFUEVMICg2KSA8ZXBlbEBmZWRvcmFwcm9qZWN0Lm9yZz6JAjYEEwECACAFAkvS
KUICGw8GCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRA7Sd8qBgi4lR/GD/wLGPv9
qO39eyb9NlrwfKdUEo1tHxKdrhNz+XYrO4yVDTBZRPSuvL2yaoeSIhQOKhNPfEgT
9mdsbsgcfmoHxmGVcn+lbheWsSvcgrXuz0gLt8TGGKGGROAoLXpuUsb1HNtKEOwP
Q4z1uQ2nOz5hLRyDOV0I2LwYV8BjGIjBKUMFEUxFTsL7XOZkrAg/WbTH2PW3hrfS
WtcRA7EYonI3B80d39ffws7SmyKbS5PmZjqOPuTvV2F0tMhKIhncBwoojWZPExft
HpKhzKVh8fdDO/3P1y1Fk3Cin8UbCO9MWMFNR27fVzCANlEPljsHA+3Ez4F7uboF
p0OOEov4Yyi4BEbgqZnthTG4ub9nyiupIZ3ckPHr3nVcDUGcL6lQD/nkmNVIeLYP
x1uHPOSlWfuojAYgzRH6LL7Idg4FHHBA0to7FW8dQXFIOyNiJFAOT2j8P5+tVdq8
wB0PDSH8yRpn4HdJ9RYquau4OkjluxOWf0uRaS//SUcCZh+1/KBEOmcvBHYRZA5J
l/nakCgxGb2paQOzqqpOcHKvlyLuzO5uybMXaipLExTGJXBlXrbbASfXa/yGYSAG
iVrGz9CE6676dMlm8F+s3XXE13QZrXmjloc6jwOljnfAkjTGXjiB7OULESed96MR
XtfLk0W5Ab9pd7tKDR6QHI7rgHXfCopRnZ2VVQ==
=V/6I
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key5
rpm --import /tmp/gpg-key-5
cat > /tmp/gpg-key-6 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.7 (GNU/Linux)

mI0ESAP+VwEEAMZylR8dOijUPNn3He3GdgM/kOXEhn3uQl+sRMNJUDm1qebi2D5b
Qa7GNBIlXm3DEMAS+ZlkiFQ4WnhUq5awEXU7MGcWCEGfums5FckV2tysSfn7HeWd
9mkEnsY2CUZF54lyKfY0f+vdFd6QdYo6b+YxGnLyiunEYHXSEo1TNj1vABEBAAG0
QlZNd2FyZSwgSW5jLiAtLSBMaW51eCBQYWNrYWdpbmcgS2V5IC0tIDxsaW51eC1w
YWNrYWdlc0B2bXdhcmUuY29tPoi8BBMBAgAmBQJIA/5XAhsDBQkRcu4ZBgsJCAcD
AgQVAggDBBYCAwECHgECF4AACgkQwLXgq2b9SUkw0AP/UlmWQIjMNcYfTKCOOyFx
Csl3bY5OZ6HZs4qCRvzESVTyKs0YN1gX5YDDRmE5EbaqSO7OLriA7p81CYhstYID
GjVTBqH/zJz/DGKQUv0A7qGvnX4MDt/cvvgEXjGpeRx42le/mkPsHdwbG/8jKveY
S/eu0g9IenS49i0hcOnjShGIRgQQEQIABgUCSAQWfAAKCRD1ZoIQEyn810LTAJ9k
IOziCqa/awfBvlLq4eRgN/NnkwCeJLOuL6eAueYjaODTcFEGKUXlgM4=
=bXtp
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key6
rpm --import /tmp/gpg-key-6
cat > /tmp/gpg-key-7 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.10 (MingW32)

mQENBFC+QboBCAC1bodHD7AmR00SkDMB4u9MXy+Z5vv8wbmGRaKDBYScpAknOljX
d5tBADffAetd1hgLnrLKN8vHdIsYkmUyeEeEsnIUKtwvbx/f6PoZZPOIIIRh1d2W
Mjw9qXIE+tgr2gWlq0Gi5BZzaKse1+khRQ2rewJBppblSGWgcmCMIq8OwAsrdbtr
z7+37c/g/Y2VfAahc23YZW9LQ5MiaI4nS4JMZbWPYtBdF78B/D2t5FvmvDG0Cgjk
Qi1U9IVjiFKixuoi6nRsvBLFYL/cI+vo4iyUC5x7qmKd8gN7A030gS67VrleNRki
q0vaF6J46XpIl4o58t23FSAKKRbTwavYzdMpABEBAAG0NEhld2xldHQtUGFja2Fy
ZCBDb21wYW55IFJTQSAoSFAgQ29kZXNpZ25pbmcgU2VydmljZSmJAT4EEwECACgF
AlC+QboCGwMFCRLMAwAGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJELBwaApc
4tR2x7sH/A3D4XxEEyrX6Z3HeWSSA80+n+r5QwfXm5unxsWEL3JyNg6sojlrJY4K
8k4ih4nkY4iblChTCSQwnqKXqkL5U+RIr+AJoPx+55M98u4eRTVYMHZD7/jFq85z
ZFGUkFkars9E2aRzWhqbz0LINb9OUeX0tT5qQseHflO2PaJykxNPC14WhsBKC2lg
dZWnGhO5QJFp69AnSp4k+Uo/1LMk87YEJIL1NDR0lrlKgRvFfFyTpRBt+Qb1Bb7g
rjN0171g8t5GaPWamN3Oua/v4aZg15f3xydRF8y9TsYjiNz+2TzRjKv7AkpZaJST
06CqMjCgiZ6UFFGN0/oqLnwxdP3Mmh4=
=aphN
-----END PGP PUBLIC KEY BLOCK-----



EOF
# gpg-key7
rpm --import /tmp/gpg-key-7
cat > /tmp/gpg-key-8 <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)

mQINBEw3u0ABEAC1+aJQpU59fwZ4mxFjqNCgfZgDhONDSYQFMRnYC1dzBpJHzI6b
fUBQeaZ8rh6N4kZ+wq1eL86YDXkCt4sCvNTP0eF2XaOLbmxtV9bdpTIBep9bQiKg
5iZaz+brUZlFk/MyJ0Yz//VQ68N1uvXccmD6uxQsVO+gx7rnarg/BGuCNaVtGwy+
S98g8Begwxs9JmGa8pMCcSxtC7fAfAEZ02cYyrw5KfBvFI3cHDdBqrEJQKwKeLKY
GHK3+H1TM4ZMxPsLuR/XKCbvTyl+OCPxU2OxPjufAxLlr8BWUzgJv6ztPe9imqpH
Ppp3KuLFNorjPqWY5jSgKl94W/CO2x591e++a1PhwUn7iVUwVVe+mOEWnK5+Fd0v
VMQebYCXS+3dNf6gxSvhz8etpw20T9Ytg4EdhLvCJRV/pYlqhcq+E9le1jFOHOc0
Nc5FQweUtHGaNVyn8S1hvnvWJBMxpXq+Bezfk3X8PhPT/l9O2lLFOOO08jo0OYiI
wrjhMQQOOSZOb3vBRvBZNnnxPrcdjUUm/9cVB8VcgI5KFhG7hmMCwH70tpUWcZCN
NlI1wj/PJ7Tlxjy44f1o4CQ5FxuozkiITJvh9CTg+k3wEmiaGz65w9jRl9ny2gEl
f4CR5+ba+w2dpuDeMwiHJIs5JsGyJjmA5/0xytB7QvgMs2q25vWhygsmUQARAQAB
tEdQdXBwZXQgTGFicyBSZWxlYXNlIEtleSAoUHVwcGV0IExhYnMgUmVsZWFzZSBL
ZXkpIDxpbmZvQHB1cHBldGxhYnMuY29tPokCPgQTAQIAKAIbAwYLCQgHAwIGFQgC
CQoLBBYCAwECHgECF4AFAk/x5PoFCQtIMjoACgkQEFS3okvW7DAIKQ/9HvZyf+LH
VSkCk92Kb6gckniin3+5ooz67hSr8miGBfK4eocqQ0H7bdtWjAILzR/IBY0xj6OH
KhYP2k8TLc7QhQjt0dRpNkX+Iton2AZryV7vUADreYz44B0bPmhiE+LL46ET5ITh
LKu/KfihzkEEBa9/t178+dO9zCM2xsXaiDhMOxVE32gXvSZKP3hmvnK/FdylUY3n
WtPedr+lHpBLoHGaPH7cjI+MEEugU3oAJ0jpq3V8n4w0jIq2V77wfmbD9byIV7dX
cxApzciK+ekwpQNQMSaceuxLlTZKcdSqo0/qmS2A863YZQ0ZBe+Xyf5OI33+y+Mr
y+vl6Lre2VfPm3udgR10E4tWXJ9Q2CmG+zNPWt73U1FD7xBI7PPvOlyzCX4QJhy2
Fn/fvzaNjHp4/FSiCw0HvX01epcersyun3xxPkRIjwwRM9m5MJ0o4hhPfa97zibX
Sh8XXBnosBQxeg6nEnb26eorVQbqGx0ruu/W2m5/JpUfREsFmNOBUbi8xlKNS5CZ
ypH3Zh88EZiTFolOMEh+hT6s0l6znBAGGZ4m/Unacm5yDHmg7unCk4JyVopQ2KHM
oqG886elu+rm0ASkhyqBAk9sWKptMl3NHiYTRE/m9VAkugVIB2pi+8u84f+an4Hm
l4xlyijgYu05pqNvnLRyJDLd61hviLC8GYU=
=qHKb
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key8
rpm --import /tmp/gpg-key-8
cat > /tmp/gpg-key-9 <<'EOF'
The following public key can be used to verify RPM packages built and
signed by Red Hat, Inc.  This key is used for packages in Red Hat
products shipped after November 2006, and for all updates to those
products.

Questions about this key should be sent to security@redhat.com.

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.2.6 (GNU/Linux)

mQGiBEV2EyQRBAD4/SR69qoLzK4HIa6g9iS+baiX0o3NjkLftFHg/xy+IMOMg//i
4c5bUpLKDTMH3+yT0G8qpul/RALUFOESKFkZm3/SlkJKuroXcB8U6s2dh5XX9DDB
ISqRwL7M5qB8rfDPKHN+k/XwJ9CNpHMdNxnnc2WhnnmHNp6NrD/bUEH4vwCglMa0
rFRXPaN7407DARGHvW/jugsEANFaeZsFwos/sajL1XQRfHZUTnvDjJgz31IFY+OL
DlOVAOtV/NaECMwIJsMIhoisW4Luwp4m75Qh3ogq3bwqSWNLsfJ9WFnNqXOgamyD
h/F4q492z6FpyIb1JZLABBSH7LEQjHlR/s/Ct5JEWc5MyfzdjBi6J9qCh3y/IYL0
EbfRA/4yoJ/fH9uthDLZsZRWmnGJvb+VpRvcVs8IQ4aIAcOMbWu2Sp3U9pm6cxZF
N7tShmAwiiGj9UXVtlhpj3lnqulLMD9VqXGF0YgDOaQ7CP/99OEEhUjBj/8o8udF
gxc1i2WJjc7/sr8IMbDv/SNToi0bnZUxXa/BUjj92uaQ6/LupbQxUmVkIEhhdCwg
SW5jLiAocmVsZWFzZSBrZXkpIDxzZWN1cml0eUByZWRoYXQuY29tPohfBBMRAgAf
BQJFdhMkAhsDBgsJCAcDAgQVAggDAxYCAQIeAQIXgAAKCRBTJoEBNwFxhogXAKCD
TuYeyQrkYXjg9JmOdTZvsIVfZgCcCWKJXtfbC5dbv0piTHI/cdwVzJo=
=mhzo
-----END PGP PUBLIC KEY BLOCK-----

EOF
# gpg-key9
rpm --import /tmp/gpg-key-9
cat > /tmp/ssl-key-1 <<'EOF'
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 0 (0x0)
        Signature Algorithm: md5WithRSAEncryption
        Issuer: C=US, ST=North Carolina, L=Raleigh, O=Red Hat, Inc., OU=Red Hat Network, CN=RHN Certificate Authority/emailAddress=rhn-noc@redhat.com
        Validity
            Not Before: Aug 29 02:10:55 2003 GMT
            Not After : Aug 26 02:10:55 2013 GMT
        Subject: C=US, ST=North Carolina, L=Raleigh, O=Red Hat, Inc., OU=Red Hat Network, CN=RHN Certificate Authority/emailAddress=rhn-noc@redhat.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (1024 bit)
                Modulus (1024 bit):
                    00:bf:61:63:eb:3d:8b:2b:45:48:e6:c2:fb:7c:d2:
                    21:21:b8:ec:90:93:41:30:7c:2c:8d:79:d5:14:e9:
                    0e:7e:3f:ef:d6:0a:9b:0a:a6:02:52:01:2d:26:96:
                    a4:ed:bd:a9:9e:aa:08:03:c1:61:0a:41:80:ea:ae:
                    74:cc:61:26:d0:05:91:55:3e:66:14:a2:20:b3:d6:
                    9d:71:0c:ab:77:cc:f4:f0:11:b5:25:33:8a:4e:22:
                    9a:10:36:67:fa:11:6d:48:76:3a:1f:d2:e3:44:7b:
                    89:66:be:b4:85:fb:2f:a6:aa:13:fa:9a:6d:c9:bb:
                    18:c4:04:af:4f:15:69:89:9b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
            69:44:27:05:DC:2E:ED:A5:F4:81:C4:D7:78:45:E7:44:5D:F8:87:47
            X509v3 Authority Key Identifier:
            keyid:69:44:27:05:DC:2E:ED:A5:F4:81:C4:D7:78:45:E7:44:5D:F8:87:47
            DirName:/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Red Hat Network/CN=RHN Certificate Authority/emailAddress=rhn-noc@redhat.com
            serial:00

            X509v3 Basic Constraints:
            CA:TRUE
    Signature Algorithm: md5WithRSAEncryption
        23:c9:ca:07:9f:5e:96:39:83:e0:4e:da:dd:47:84:30:ca:d4:
        d5:38:86:f9:de:88:83:ca:2c:47:26:36:ab:f4:14:1e:28:29:
        de:7d:10:4a:5e:91:3e:5a:99:07:0c:a9:2e:e3:fb:78:44:49:
        c5:32:d6:e8:7a:97:ff:29:d0:33:ae:26:ba:76:06:7e:79:97:
        17:0c:4f:2d:2a:8b:8a:ac:41:59:ae:e9:c4:55:2d:b9:88:df:
        9b:7b:41:f8:32:2e:ee:c9:c0:59:e2:30:57:5e:37:47:29:c0:
        2d:78:33:d3:ce:a3:2b:dc:84:da:bf:3b:2e:4b:b6:b3:b6:4e:
        9e:80
-----BEGIN CERTIFICATE-----
MIID7jCCA1egAwIBAgIBADANBgkqhkiG9w0BAQQFADCBsTELMAkGA1UEBhMCVVMx
FzAVBgNVBAgTDk5vcnRoIENhcm9saW5hMRAwDgYDVQQHEwdSYWxlaWdoMRYwFAYD
VQQKEw1SZWQgSGF0LCBJbmMuMRgwFgYDVQQLEw9SZWQgSGF0IE5ldHdvcmsxIjAg
BgNVBAMTGVJITiBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEW
EnJobi1ub2NAcmVkaGF0LmNvbTAeFw0wMzA4MjkwMjEwNTVaFw0xMzA4MjYwMjEw
NTVaMIGxMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGggQ2Fyb2xpbmExEDAO
BgNVBAcTB1JhbGVpZ2gxFjAUBgNVBAoTDVJlZCBIYXQsIEluYy4xGDAWBgNVBAsT
D1JlZCBIYXQgTmV0d29yazEiMCAGA1UEAxMZUkhOIENlcnRpZmljYXRlIEF1dGhv
cml0eTEhMB8GCSqGSIb3DQEJARYScmhuLW5vY0ByZWRoYXQuY29tMIGfMA0GCSqG
SIb3DQEBAQUAA4GNADCBiQKBgQC/YWPrPYsrRUjmwvt80iEhuOyQk0EwfCyNedUU
6Q5+P+/WCpsKpgJSAS0mlqTtvameqggDwWEKQYDqrnTMYSbQBZFVPmYUoiCz1p1x
DKt3zPTwEbUlM4pOIpoQNmf6EW1Idjof0uNEe4lmvrSF+y+mqhP6mm3JuxjEBK9P
FWmJmwIDAQABo4IBEjCCAQ4wHQYDVR0OBBYEFGlEJwXcLu2l9IHE13hF50Rd+IdH
MIHeBgNVHSMEgdYwgdOAFGlEJwXcLu2l9IHE13hF50Rd+IdHoYG3pIG0MIGxMQsw
CQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcTB1Jh
bGVpZ2gxFjAUBgNVBAoTDVJlZCBIYXQsIEluYy4xGDAWBgNVBAsTD1JlZCBIYXQg
TmV0d29yazEiMCAGA1UEAxMZUkhOIENlcnRpZmljYXRlIEF1dGhvcml0eTEhMB8G
CSqGSIb3DQEJARYScmhuLW5vY0ByZWRoYXQuY29tggEAMAwGA1UdEwQFMAMBAf8w
DQYJKoZIhvcNAQEEBQADgYEAI8nKB59eljmD4E7a3UeEMMrU1TiG+d6Ig8osRyY2
q/QUHigp3n0QSl6RPlqZBwypLuP7eERJxTLW6HqX/ynQM64munYGfnmXFwxPLSqL
iqxBWa7pxFUtuYjfm3tB+DIu7snAWeIwV143RynALXgz086jK9yE2r87Lku2s7ZO
noA=
-----END CERTIFICATE-----

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 42 (0x2a)
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=US, ST=North Carolina, L=Raleigh, O=Red Hat, Inc., OU=Red Hat Network, CN=RHN Certificate Authority/emailAddress=rhn-noc@redhat.com
        Validity
            Not Before: Feb 26 21:07:08 2010 GMT
            Not After : Feb 24 21:07:08 2020 GMT
        Subject: C=US, ST=North Carolina, L=Raleigh, O=Red Hat, Inc., OU=Red Hat Network, CN=RHN Certificate Authority/emailAddress=rhn-noc@redhat.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:a9:51:91:f5:5e:ae:cd:8b:5f:8e:c6:1c:64:f5:
                    8c:68:b0:b3:8b:1d:29:2d:95:ff:87:46:8e:93:dc:
                    2a:92:17:9d:60:38:cb:c8:9a:a1:24:fa:ff:21:de:
                    a6:f8:4a:ba:87:a8:c7:6a:d4:64:cd:37:e9:37:ec:
                    5d:56:3b:7c:d3:94:13:89:a5:cb:23:f0:80:7d:07:
                    6e:ca:fd:cf:6c:ea:cc:bb:ab:ff:b8:a3:cb:ec:9a:
                    ab:77:fe:ae:5a:a3:54:36:a6:aa:96:bc:9d:3c:ce:
                    af:3c:48:18:70:26:b4:b0:c1:40:cf:c8:23:21:46:
                    4c:d1:ed:71:bc:8e:e8:54:df:55:06:b3:a1:30:56:
                    25:f5:5d:ab:8e:4a:66:4f:1b:df:53:9c:8c:3c:11:
                    92:d1:11:a4:82:c6:69:ee:9a:94:83:56:de:0c:ba:
                    9d:1c:21:bb:8c:33:7d:aa:6e:d9:97:3a:c8:92:8f:
                    e0:bd:27:dc:71:e2:b6:b0:e3:82:46:5f:08:ba:86:
                    65:18:a9:a5:c2:b6:7d:4d:7c:fe:3f:dd:72:0d:a0:
                    fc:ec:46:1b:24:b5:e1:9b:01:37:66:57:0a:22:00:
                    22:20:d6:74:ca:cd:8b:66:72:62:39:e9:67:52:d6:
                    e3:2b:7e:7c:aa:cf:7d:61:c3:7e:0f:38:bd:b5:17:
                    ad:f9
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                15:F1:11:00:0A:34:A1:A2:56:BB:2F:57:1E:59:E2:7F:6A:CF:EA:43
            X509v3 Authority Key Identifier:
                keyid:15:F1:11:00:0A:34:A1:A2:56:BB:2F:57:1E:59:E2:7F:6A:CF:EA:43
                DirName:/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Red Hat Network/CN=RHN Certificate Authority/emailAddress=rhn-noc@redhat.com
                serial:2A

            X509v3 Basic Constraints:
                CA:TRUE
    Signature Algorithm: sha1WithRSAEncryption
        2d:1b:a6:e7:df:b2:9e:2e:e4:1a:4d:e1:58:97:c2:82:18:10:
        f6:79:69:02:12:4c:72:cc:e4:09:c8:43:90:5e:a5:ee:da:04:
        72:10:1a:6a:09:32:73:a8:6d:ba:81:f2:fe:b1:bb:1f:89:87:
        69:d7:d9:15:c7:29:15:c5:21:f4:a4:f2:45:c9:cf:1d:dd:9e:
        56:ae:55:85:03:53:1f:54:6b:93:18:f2:02:ed:bb:5a:1b:74:
        aa:64:56:49:9c:2f:d9:0d:5b:3f:03:5a:5f:e2:19:6b:12:a7:
        0f:b5:72:52:0d:95:f9:15:a7:28:e2:8a:c2:69:88:87:b8:42:
        57:65:06:94:94:1d:15:d6:ad:7a:60:05:fb:f9:cc:83:09:b5:
        41:07:5d:78:ec:a6:da:6a:23:77:6f:b9:9a:4b:60:30:53:bb:
        e4:7e:5e:51:7c:a9:11:79:b8:3c:f4:19:8d:f3:5a:27:7f:ff:
        4c:e7:44:e0:e4:e6:0e:18:55:d7:68:72:22:7a:30:76:9b:26:
        84:d6:d8:20:40:ef:8e:45:75:94:d0:86:2c:a8:af:bc:31:2d:
        50:20:eb:d1:16:55:e6:3e:8b:82:ed:fb:dd:a3:a0:f7:6b:7e:
        d6:b8:5f:45:a5:0b:72:7b:7e:6d:20:7f:60:95:67:ad:96:12:
        ba:6b:e7:6c
-----BEGIN CERTIFICATE-----
MIIE8zCCA9ugAwIBAgIBKjANBgkqhkiG9w0BAQUFADCBsTELMAkGA1UEBhMCVVMx
FzAVBgNVBAgMDk5vcnRoIENhcm9saW5hMRAwDgYDVQQHDAdSYWxlaWdoMRYwFAYD
VQQKDA1SZWQgSGF0LCBJbmMuMRgwFgYDVQQLDA9SZWQgSGF0IE5ldHdvcmsxIjAg
BgNVBAMMGVJITiBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEW
EnJobi1ub2NAcmVkaGF0LmNvbTAeFw0xMDAyMjYyMTA3MDhaFw0yMDAyMjQyMTA3
MDhaMIGxMQswCQYDVQQGEwJVUzEXMBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAO
BgNVBAcMB1JhbGVpZ2gxFjAUBgNVBAoMDVJlZCBIYXQsIEluYy4xGDAWBgNVBAsM
D1JlZCBIYXQgTmV0d29yazEiMCAGA1UEAwwZUkhOIENlcnRpZmljYXRlIEF1dGhv
cml0eTEhMB8GCSqGSIb3DQEJARYScmhuLW5vY0ByZWRoYXQuY29tMIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqVGR9V6uzYtfjsYcZPWMaLCzix0pLZX/
h0aOk9wqkhedYDjLyJqhJPr/Id6m+Eq6h6jHatRkzTfpN+xdVjt805QTiaXLI/CA
fQduyv3PbOrMu6v/uKPL7Jqrd/6uWqNUNqaqlrydPM6vPEgYcCa0sMFAz8gjIUZM
0e1xvI7oVN9VBrOhMFYl9V2rjkpmTxvfU5yMPBGS0RGkgsZp7pqUg1beDLqdHCG7
jDN9qm7ZlzrIko/gvSfcceK2sOOCRl8IuoZlGKmlwrZ9TXz+P91yDaD87EYbJLXh
mwE3ZlcKIgAiINZ0ys2LZnJiOelnUtbjK358qs99YcN+Dzi9tRet+QIDAQABo4IB
EjCCAQ4wHQYDVR0OBBYEFBXxEQAKNKGiVrsvVx5Z4n9qz+pDMIHeBgNVHSMEgdYw
gdOAFBXxEQAKNKGiVrsvVx5Z4n9qz+pDoYG3pIG0MIGxMQswCQYDVQQGEwJVUzEX
MBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVpZ2gxFjAUBgNV
BAoMDVJlZCBIYXQsIEluYy4xGDAWBgNVBAsMD1JlZCBIYXQgTmV0d29yazEiMCAG
A1UEAwwZUkhOIENlcnRpZmljYXRlIEF1dGhvcml0eTEhMB8GCSqGSIb3DQEJARYS
cmhuLW5vY0ByZWRoYXQuY29tggEqMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEF
BQADggEBAC0bpuffsp4u5BpN4ViXwoIYEPZ5aQISTHLM5AnIQ5Bepe7aBHIQGmoJ
MnOobbqB8v6xux+Jh2nX2RXHKRXFIfSk8kXJzx3dnlauVYUDUx9Ua5MY8gLtu1ob
dKpkVkmcL9kNWz8DWl/iGWsSpw+1clINlfkVpyjiisJpiIe4QldlBpSUHRXWrXpg
Bfv5zIMJtUEHXXjsptpqI3dvuZpLYDBTu+R+XlF8qRF5uDz0GY3zWid//0znRODk
5g4YVddociJ6MHabJoTW2CBA745FdZTQhiyor7wxLVAg69EWVeY+i4Lt+92joPdr
fta4X0WlC3J7fm0gf2CVZ62WErpr52w=
-----END CERTIFICATE-----


EOF
# ssl-key1
cat > /tmp/ssl-key-2 <<'EOF'
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            91:d1:1b:85:60:0c:67:66
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=US
        Validity
            Not Before: Aug 26 15:11:52 2011 GMT
            Not After : Jan 18 15:11:52 2038 GMT
        Subject: C=US
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (2048 bit)
                Modulus (2048 bit):
                    00:d1:35:48:0a:ff:dd:f1:23:8d:42:2e:49:56:97:
                    4f:45:d9:5c:24:47:07:8c:03:04:e0:2d:54:e8:10:
                    24:25:ed:b7:9c:60:c2:94:47:58:e5:7e:ff:06:99:
                    83:d3:02:4d:33:5d:1a:9f:89:ef:2a:3c:37:a5:56:
                    77:10:08:95:c1:5b:d9:87:93:86:d4:03:bb:98:21:
                    d8:48:f6:d6:56:53:34:71:9b:11:81:a5:29:e6:8a:
                    d4:cc:4e:8a:5e:cb:46:c2:9c:7b:99:83:c9:ff:1e:
                    a5:10:b2:f8:b1:83:51:e2:fa:e1:d0:7f:e7:1e:c2:
                    98:38:b1:c3:d3:2a:7b:43:87:18:7d:f2:5b:cd:e3:
                    e3:16:bb:64:b5:b6:93:3b:4d:27:a3:eb:f6:d2:ad:
                    07:54:96:03:8c:10:dd:9f:f3:cf:4c:a5:54:7a:9f:
                    09:88:55:b8:e1:a0:3c:eb:76:af:54:19:a2:b9:6a:
                    dc:51:2f:5f:46:9c:5f:33:96:22:4f:07:2c:67:5f:
                    7c:82:c1:48:2a:5a:71:e1:32:d9:85:b9:d7:e3:c9:
                    a1:20:98:98:31:45:c3:7e:76:f1:e7:31:9b:84:f8:
                    6b:2e:6a:97:d1:38:3e:be:27:80:dd:a0:83:63:92:
                    4f:91:53:6f:f3:06:3b:d8:c3:f0:72:d4:32:76:b0:
                    23:f3
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:TRUE
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment, Certificate Sign
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication, TLS Web Client Authentication
            Netscape Comment: 
                RHN SSL Tool Generated Certificate
            X509v3 Subject Key Identifier: 
                53:DF:6E:6E:85:F3:08:F0:59:9B:9C:20:AB:80:91:57:6F:D7:3F:33
            X509v3 Authority Key Identifier: 
                keyid:53:DF:6E:6E:85:F3:08:F0:59:9B:9C:20:AB:80:91:57:6F:D7:3F:33
                DirName:/C=US
                serial:91:D1:1B:85:60:0C:67:66

    Signature Algorithm: sha1WithRSAEncryption
        4b:9a:e2:38:b1:62:2b:50:fc:81:44:eb:dd:f8:67:46:c9:f2:
        22:91:24:03:4e:09:ed:fc:cd:f5:b7:4b:77:16:5e:e2:f1:33:
        dc:d9:46:0d:0b:a2:bc:e6:c8:72:1f:3f:81:b6:3e:99:df:ec:
        46:98:f7:96:20:ef:31:13:52:ca:87:87:73:83:d6:1c:fb:0b:
        6f:1e:47:24:9a:e6:2c:bd:0f:ba:0c:9d:a5:45:71:28:16:d9:
        72:3d:8f:5e:5b:c3:16:59:63:66:ba:18:fd:89:12:bc:10:eb:
        0b:46:81:c8:56:af:37:e7:64:01:68:38:f7:11:91:88:18:27:
        f9:8d:3a:87:96:55:18:58:1a:bc:a0:b4:2e:2e:7c:2d:79:7e:
        1a:6d:54:b1:48:0b:43:68:e2:ae:1d:fc:f3:12:ef:5b:49:d0:
        0a:d7:22:c8:35:48:5a:c7:c4:b2:7e:b2:53:3d:13:ac:a0:a0:
        fd:63:25:b1:93:9f:e5:49:2a:86:95:c5:79:bf:ef:40:1c:cf:
        10:f8:d7:9d:e0:ec:1e:31:d1:91:0a:0f:a1:08:5d:d5:8a:51:
        c7:32:11:b1:b1:ee:4c:f3:b3:cc:e4:c9:b6:e2:79:49:47:50:
        4a:59:19:37:90:ac:55:87:9c:af:c9:5c:58:58:eb:44:7a:a0:
        5a:f3:00:5f
-----BEGIN CERTIFICATE-----
MIIDbDCCAlSgAwIBAgIJAJHRG4VgDGdmMA0GCSqGSIb3DQEBBQUAMA0xCzAJBgNV
BAYTAlVTMB4XDTExMDgyNjE1MTE1MloXDTM4MDExODE1MTE1MlowDTELMAkGA1UE
BhMCVVMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDRNUgK/93xI41C
LklWl09F2VwkRweMAwTgLVToECQl7becYMKUR1jlfv8GmYPTAk0zXRqfie8qPDel
VncQCJXBW9mHk4bUA7uYIdhI9tZWUzRxmxGBpSnmitTMTopey0bCnHuZg8n/HqUQ
svixg1Hi+uHQf+cewpg4scPTKntDhxh98lvN4+MWu2S1tpM7TSej6/bSrQdUlgOM
EN2f889MpVR6nwmIVbjhoDzrdq9UGaK5atxRL19GnF8zliJPByxnX3yCwUgqWnHh
MtmFudfjyaEgmJgxRcN+dvHnMZuE+GsuapfROD6+J4DdoINjkk+RU2/zBjvYw/By
1DJ2sCPzAgMBAAGjgc4wgcswDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAqQwHQYD
VR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMDEGCWCGSAGG+EIBDQQkFiJSSE4g
U1NMIFRvb2wgR2VuZXJhdGVkIENlcnRpZmljYXRlMB0GA1UdDgQWBBRT325uhfMI
8FmbnCCrgJFXb9c/MzA9BgNVHSMENjA0gBRT325uhfMI8FmbnCCrgJFXb9c/M6ER
pA8wDTELMAkGA1UEBhMCVVOCCQCR0RuFYAxnZjANBgkqhkiG9w0BAQUFAAOCAQEA
S5riOLFiK1D8gUTr3fhnRsnyIpEkA04J7fzN9bdLdxZe4vEz3NlGDQuivObIch8/
gbY+md/sRpj3liDvMRNSyoeHc4PWHPsLbx5HJJrmLL0PugydpUVxKBbZcj2PXlvD
FlljZroY/YkSvBDrC0aByFavN+dkAWg49xGRiBgn+Y06h5ZVGFgavKC0Li58LXl+
Gm1UsUgLQ2jirh388xLvW0nQCtciyDVIWsfEsn6yUz0TrKCg/WMlsZOf5UkqhpXF
eb/vQBzPEPjXneDsHjHRkQoPoQhd1YpRxzIRsbHuTPOzzOTJtuJ5SUdQSlkZN5Cs
VYecr8lcWFjrRHqgWvMAXw==
-----END CERTIFICATE-----

EOF
# ssl-key2
cat /tmp/ssl-key-* > /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
perl -pe 's/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/g' -i /etc/sysconfig/rhn/up2date

mkdir -p /tmp/rhn_rpms/optional
cd /tmp/rhn_rpms/optional 
wget -P /tmp/rhn_rpms/optional http://rhns01.wal-mart.com/download/package/5d15917a43df1a132f623eaac50da364fe5e0172/0/1/101195/libxml2-python-2.7.6-17.el6_6.1.x86_64.rpm http://rhns01.wal-mart.com/download/package/b70345b7cf50d8cc17801c3722cb67d4e90b7fd1/0/1/22146/pyOpenSSL-0.10-2.el6.x86_64.rpm http://rhns01.wal-mart.com/download/package/0a65daf20cebbf27e943aa087d550cbc96747a84/0/1/101196/libxml2-2.7.6-17.el6_6.1.x86_64.rpm http://rhns01.wal-mart.com/download/package/983e7ba04c28bf69d941d89a950aa8a35e1e3b39/0/1/60119/rhnlib-2.5.22-15.el6.noarch.rpm 
rpm -Uvh --replacepkgs --replacefiles /tmp/rhn_rpms/optional/pyOpenSSL* /tmp/rhn_rpms/optional/rhnlib* /tmp/rhn_rpms/optional/libxml2-python* /tmp/rhn_rpms/optional/libxml2* 
perl -npe 's|^(\s*(noSSLS\|s)erverURL\s*=\s*[^:]+://)[^/]*/|${1}rhns01.wal-mart.com/|' -i /etc/sysconfig/rhn/up2date
mkdir -p /etc/sysconfig/rhn/allowed-actions/script
touch /etc/sysconfig/rhn/allowed-actions/script/run
mkdir -p /etc/sysconfig/rhn/allowed-actions/configfiles
touch /etc/sysconfig/rhn/allowed-actions/configfiles/all

# now copy from the ks-tree we saved in the non-chroot checkout
cp -fav /tmp/ks-tree-copy/* / 2>/dev/null
rm -Rf /tmp/ks-tree-copy
# --End Red Hat Satellite command section--

# begin cobbler snippet
# set default MOTD
echo "Kickstarted on $(date +'%Y-%m-%d')" >> /etc/motd

# begin Red Hat management server registration
mkdir -p /usr/share/rhn/
wget http://rhns01.wal-mart.com/pub/RHN-ORG-TRUSTED-SSL-CERT -O /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT   
perl -Xnpe 's/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/g' -i /etc/sysconfig/rhn/*  
if [ -f /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release ]; then
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
fi
key=1-533973c0d67e7cfb4ebe5dddd2f53559,1-HO-Standard-RHEL-6-Production
if [ -f /tmp/key ]; then
    key=`cat /tmp/key`,$key
fi

rhnreg_ks --serverUrl=https://rhns01.wal-mart.com/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=$key
# end Red Hat management server registration

# end cobbler snippet

rhn_check

# Start post_install_network_config generated code
# End post_install_network_config generated code

#####################################################################

Oslevel=$( rpm -q --queryformat="%{VERSION}\n" redhat-release-server )
# ------------------------------------
# Get_Cmdline_Params
# ------------------------------------
# Grab any parameters passed to the kernel and make them available as variables
for Param in $( cat /proc/cmdline )
do
        case "$Param" in    
                *=*) eval $Param ;;
        esac 
done

# ------------------------------------
# HO_Standard_Configure_etc_resolv.conf
# ------------------------------------
# This configuration may get overwritten in later post install steps, but this will serve to provide initial name resolution during kickstart

echo "dns=none" >> /etc/NetworkManager/NetworkManager.conf 2>/dev/null

echo -e "# /etc/resolv.conf - Generated during kickstart
domain homeoffice.wal-mart.com
nameserver 161.173.7.10
nameserver 161.173.7.20
search homeoffice.wal-mart.com. wal-mart.com. walmart.com." > /etc/resolv.conf

# ------------------------------------
# HO_Standard_Configure_etc_hosts
# ------------------------------------
# If DHCP, exit without modifying hosts file
# Determine Primary NIC
PrimaryNIC=$( ip route | awk '$1=="default" { print $5 }' | head -1 )

# Determine IP Address of primary NIC
if [[ $( rpm -q --queryformat="%{VERSION}\n" redhat-release-server ) =~ ^6 ]] ;then 
    #RHEL6
    IPAddress=$( ifconfig $PrimaryNIC | grep 'inet addr'| awk '{print $2}' | awk -F: '{ print $2 }' )
else
    #RHEL7+
    IPAddress=$( ifconfig $PrimaryNIC | grep 'inet'| awk '{print $2}' )
fi

DeviceFile="/etc/sysconfig/network-scripts/ifcfg-${PrimaryNIC:=eth0}"
BootProto=$( awk -F= '$1=="BOOTPROTO" { print $2 }' $DeviceFile | sed "s/\"//g" )
if [[ "$BootProto" = "dhcp" ]] ;then
    echo "Primary interface uses DHCP.  Skipping /etc/hosts configuration"
else
    [[ -z "$domain" ]] && domain="wal-mart.com"
    HN=$( hostname | sed "s/\.${domain}//g" )
    echo -e "# Generated during kickstart
127.0.0.1   localhost.localdomain   localhost
::1     localhost6.localdomain6 localhost6
$IPAddress  ${HN}.${domain} ${HN}" > /etc/hosts
fi


# ------------------------------------
# Sync_Date_and_Time
# ------------------------------------
echo "Syncing time with ntp-1"
/usr/sbin/ntpdate ntp-1
/usr/sbin/hwclock --systohc 2>&1
# ------------------------------------
# Setup /unixadmin
# ------------------------------------

mkdir -m 700 /unixadmin 2>/dev/null
if [[ $( rpm -q --queryformat="%{VERSION}\n" redhat-release-server ) =~ ^6 ]] ;then 
    #RHEL6
    service rpcbind start
    echo "
#NFS Mounts
ndcdme06:/unixadmin  /unixadmin       nfs     rw,suid,vers=3,soft,proto=tcp,rsize=8192,wsize=8192 0 0
" >> /etc/fstab
    mount /unixadmin

else
    #RHEL7
    systemctl start rpcbind.service
fi

# ------------------------------------
# HO_Standard_Install_System_Tools
# ------------------------------------
PackageList="
rootfiles_wm
wm_misc_tools 
rmtrash
Standard-Perl
Esm_Agent
sox_alerts 
yum-plugin-remove-with-leaves
HO_DEVSERV_install
"
for Package in $( echo "$PackageList" | grep -v ^# )
do
    yum install ${Package:-none} -y
done

if [[ $Oslevel =~ "6Server" ]] ;then
    chkconfig osad on
    yum install DUS -y
fi

 
# ------------------------------------
# Packages required for ./hpsum installation of ProLiant Pack
# ------------------------------------
# yum -y install libSM
# yum -y install libXau
yum -y install libXdmcp
yum -y install kernel-headers
yum -y install redhat-rpm-config
yum -y install rpm-build
# yum -y install gcc
# ------------------------------------
# HO_Standard_Notify_IaaS
# ------------------------------------
# Post a notification that the server has completed all initial provisioning steps.  Since there is a final reboot after kickstart, put a boot script in place to execute after the final reboot.

wget -O /etc/init.d/notify_iaas http://rhns01.wal-mart.com/pub/scripts/notify_iaas
chmod 750 /etc/init.d/notify_iaas
chkconfig notify_iaas on


yum -y update --disablerepo=*third-party-apps*
/usr/bin/updatedb

# ------------------------------------
# HO_Standard_Puppet
# ------------------------------------
# Install and configure puppet

# Populate server.cfg for puppet overrides
wget -O /u/data/cfg/server.cfg http://rhns01.wal-mart.com/pub/files/server.cfg.default
if [[ "$domain" != "wal-mart.com" ]] ;then
    echo "Updating /u/data/cfg/server.cfg with overrides for: $domain"
    sed -i "s/dns_domain=/dns_domain=$domain/" /u/data/cfg/server.cfg
    sed -i "s/dns_search=/dns_search=$domain wal-mart.com homeoffice.wal-mart.com/" /u/data/cfg/server.cfg
    grep "dns_" /u/data/cfg/server.cfg
fi

# Install Puppet and dependencies
wget -O /tmp/install_puppet.ksh http://rhns01.wal-mart.com/pub/scripts/install_puppet.ksh
chmod 550 /tmp/install_puppet.ksh
# Join the correct hostgroup and environment
# 6 = Servers/HO Hostgroup
/tmp/install_puppet.ksh -h 6  -i


# ------------------------------------
# HO_Standard_chkbuild
# ------------------------------------
# This should be the very last post script executed by kickstart
# Save chkbuild ouptut
/u/bin/chkbuild -n > /root/kickstart.chkbuild.log 2>&1

########################################################################

# Start koan environment setup
echo "export COBBLER_SERVER=rhns01.wal-mart.com" > /etc/profile.d/cobbler.sh
echo "setenv COBBLER_SERVER rhns01.wal-mart.com" > /etc/profile.d/cobbler.csh
# End koan environment setup


wget "http://rhns01.wal-mart.com/cblr/svc/op/ks/profile/HO-Standard-RHEL-6-Production:1:WAL-MARTSTORESINC" -O /root/cobbler.ks
wget "http://rhns01.wal-mart.com/cblr/svc/op/trig/mode/post/profile/HO-Standard-RHEL-6-Production:1:WAL-MARTSTORESINC" -O /dev/null
