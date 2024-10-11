# INSIOS/generic-chart

![GitHub Release](https://img.shields.io/github/v/release/insios/generic-chart?filter=chart-*&label=Releases)
![GitHub Release](https://img.shields.io/github/v/release/insios/generic-chart?filter=tpl-*&label=)
![GitHub License](https://img.shields.io/github/license/insios/generic-chart)
[![Publish helm chart](https://github.com/insios/generic-chart/actions/workflows/publish-chart.yaml/badge.svg)](https://github.com/insios/generic-chart/actions/workflows/publish-chart.yaml)

A generic Helm chart for any application with any number of resources of any kind.

> [!NOTE]
> This README is currently under construction.

## Description

This chart contains a single template for rendering any Kubernetes manifests specified in the chart's values, along with a small set of helpers, allowing you to describe almost any application structure.

With this chart, you can deploy applications with any resources, including unique CRDs specific to your cluster. Additionally, the size of the chart—and therefore the `sh.helm.release.*` secrets—will remain minimal, as it won't include any unused templates, which is often the case with other generic charts.

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

## Chart values

### Application metadata

See [https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| app | object | `{}` | Application metadata |
| app.name | string | `nil` | `.Release.Name` if empty |
| app.version | string | `nil` |  |
| app.instance | string | `nil` | `.Release.Name` if empty |
| app.partOf | string | `nil` |  |
| app.environment | string | `nil` |  |

### Application components and their resources

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| components | object or list | `{}` | List of the application components |
| components[].componentName | string | `nil` |  |
| components[].resources | object or list | `{}` | List of the component resources |
| components[].resources[].resourceName | string | `nil` |  |
| components[].resources[].manifest | object | `{}` |  |

### Snippets

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| snippets | object | `{}` | Named list of the manifest's snippets |

## Special keys

Coming soon...

## Available helpers

Coming soon...

## Example templates

See [templates](templates)
