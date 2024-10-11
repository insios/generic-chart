# INSIOS/generic-chart

![GitHub Release](https://img.shields.io/github/v/release/insios/generic-chart?filter=app-*&label=Releases)
![GitHub Release](https://img.shields.io/github/v/release/insios/generic-chart?filter=tpl-*&label=)
![GitHub License](https://img.shields.io/github/license/insios/generic-chart)
[![Publish helm chart](https://github.com/insios/generic-chart/actions/workflows/publish-chart.yaml/badge.svg)](https://github.com/insios/generic-chart/actions/workflows/publish-chart.yaml)

A generic Helm chart for any application with any number of resources of any kind.

## Description

Coming soon...

## TL;DR

```shell
helm upgrade --install myapp \
    oci://ghcr.io/insios/helm/generic \
    -f ./values.yaml
```

OR

```shell
helm upgrade --install myapp \
    oci://ghcr.io/insios/helm/generic \
    -f ./myapp.generic.yaml \
    -f ./values.yaml
```

OR

```shell
helm upgrade --install myapp \
    oci://ghcr.io/insios/helm/generic \
    -f https://raw.githubusercontent.com/insios/generic-chart/refs/tags/tpl-1.0.0/templates/starter/starter.generic.yaml \
    -f ./values.yaml
```
