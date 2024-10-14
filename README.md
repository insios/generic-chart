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

List of the application components and their resources

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| components | object or list | `{}` | List of the application components |
| components[].componentName | string | `nil` |  |
| components[].resources | object or list | `{}` | List of the component resources |
| components[].resources[].resourceName | string | `nil` |  |
| components[].resources[].manifest | object | `{}` | See [reference](https://kubernetes.io/docs/reference/kubernetes-api/) |

### Snippets

Snippets can be used anywhere within the resource manifest hierarchy.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| snippets | object | `{}` | Named list of the manifest's snippets |

## Special keys

### $disabled

It can be placed in the component definition, resource definition, or anywhere within the manifest hierarchy. If evaluated to `true`, the entire object will be excluded from manifest's rendering.

Examples:

```yaml
# ...
components:
  # ...
  - componentName: 'cron'
    $disabled: '{{ eq "development" .Values.app.environment }}'
    resources:
      # ...
      - resourceName: 'sendEmails'
        manifest:
          apiVersion: batch/v1
          kind: CronJob
          # ...
      # ...
  # ...
# ...
```

```yaml
# ...
components:
  # ...
  - componentName: 'back'
    resources:
      # ...
      - resourceName: ''
        $disabled: '{{ not .Values.ingress.enabled }}'
        manifest:
          apiVersion: networking.k8s.io/v1
          kind: Ingress
          # ...
      # ...
  # ...
# ...
```

```yaml
# ...
components:
  # ...
  - componentName: 'back'
    resources:
      # ...
      - resourceName: ''
        manifest:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            # ...
          spec:
            # ...
            strategy:
              $disabled: true
              type: Recreate
            # ...
      # ...
  # ...
# ...
```

### $snippets

It can be placed anywhere within the manifest hierarchy. All snippets from this list will be merged into the object before processing any other special keys.

Examples:

```yaml
components:
  # ...
  - componentName: 'back'
    resources:
      # ...
      - resourceName: ''
        manifest:
          $snippets:
            - manifestCommon
            - manifestDeployment
          spec:
            replicas: 2
            template:
              spec:
                containers:
                  - name: back-api
                    $snippets:
                      - containerCommon
                      - containerBack
                      - containerHttp
      - resourceName: 'worker'
        manifest:
          $snippets:
            - manifestCommon
            - manifestJob
          spec:
            template:
              spec:
                containers:
                  - name: back-worker
                    $snippets:
                      - containerCommon
                      - containerBack
                    command: ['worker']
      # ...
  - componentName: 'front'
    resources:
      # ...
      - resourceName: ''
        manifest:
          $snippets:
            - manifestCommon
            - manifestDeployment
          spec:
            replicas: 1
            template:
              spec:
                containers:
                  - name: front-www
                    $snippets:
                      - containerCommon
                      - containerFront
                      - containerHttp
      # ...
  # ...

snippets:
  # ...
  manifestCommon:
    metadata:
      $name: 'fullResourceNameStr'
      $labels: 'resourceLabelsMap'
  manifestDeployment:
    apiVersion: apps/v1
    kind: Deployment
    spec:
      selector:
        $matchLabels: 'selectorLabelsMap'
      template:
        $snippets: ['podTemplateCommon']
  manifestJob:
    apiVersion: batch/v1
    kind: Job
    spec:
      template:
        $snippets: ['podTemplateCommon']
  # ...
  podTemplateCommon:
    metadata:
      $labels: 'resourceLabelsMap'
    spec:
      imagePullSecrets:
        - name: my-registry-auth
  # ...
  containerCommon:
    imagePullPolicy: IfNotPresent
  containerHttp:
    ports:
      - name: http
        containerPort: 80
        protocol: TCP
  containerBack:
    $image: 'tplStr: "myrepo/myapp-back:{{ (.Values.back).version }}"'
  containerFront:
    $image: 'tplStr: "myrepo/myapp-front:{{ (.Values.front).version }}"'
  # ...
```

### $[anyKey] (use helper template)

The full definition of using a helper template looks like:

```yaml
$anyKey:
  $disabled: false
  tplName: 'fullResourceNameStr'
  tplParam: ['dpl', 'back']
  dstKey: 'name'
  valType: 'Str'
  addEmpty: false
```

| Key       | Type              | Default | Description |
|-----------|-------------------|-------------|-------------|
| $disabled | bool or string    | false |  |
| tplName   | string            | nil | Helper template name |
| tplParam  | any               | nil | Helper template parameter (if needed) |
| dstKey    | string            | key without '$' | Destination key for the value |
| valType   | string            | end of tplName | Type of a destination key value - `Str`, `Int`, `Flt`, `Bln`, `Map` or `Lst` |
| addEmpty  | bool              | false | Add, even if the result is empty |

Short notation with parameters:

```yaml
$anyKey: 'fullResourceNameStr: ["dpl", "back"]'
```

Short notation without parameters:

```yaml
$anyKey: 'fullResourceNameStr'
```

## Available helper templates

### appNameStr

The name of the application: `.Values.app.name`, or, if it is empty - `.Release.Name`.

### appInstanceStr

The instance of the application: `.Values.app.instance`, or, if it is empty - `.Release.Name`.

### fullComponentNameStr

The full name of the component in a form `appInstanceStr[-componentName]`.

### fullResourceNameStr

The full name of the resource in a form `appInstanceStr[-componentName][-resourceName]`.

If no parameter is provided, the full name of the current resource will be used.

If a parameter is an array with one element, that element will be used as the `resourceName`.

If a parameter is an array with two elements, the first element will be used as the `resourceName`, and the second element will be used as the `componentName`.

### selectorLabelsMap

The set of resource labels used for POD selection.

The parameter is used in the same way as in `fullResourceNameStr`.

### resourceLabelsMap

The full set of resource labels.

The parameter is used in the same way as in `fullResourceNameStr`.

### tplXxx

| Name   | Return type  |
|--------|--------------|
| tplStr | string       |
| tplInt | integer      |
| tplFlt | float        |
| tplBln | boolean      |
| tplMap | object       |
| tplLst | list         |

Examples:

```yaml
$replicas: 'tplInt: "{{ .Values.replicaCount }}"'
$extraLabels:
   tplName: tplMap
   tplParam: '{{ .Values.podLabels }}'
   dstKey: 'labels'
```

## Examples

See [templates](templates)
