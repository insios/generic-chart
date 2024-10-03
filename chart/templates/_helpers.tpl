{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "generic.fullChartName" -}}
{{- printf "%s-%s" .helm.Chart.Name .helm.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the app.
*/}}
{{- define "generic.appName" -}}
{{- default .helm.Release.Name (.helm.Values.app).name }}
{{- end }}

{{/*
Expand the instance of the app.
*/}}
{{- define "generic.appInstance" -}}
{{- default .helm.Release.Name (.helm.Values.app).instance }}
{{- end }}

{{/*
Expand the full name of the component.
*/}}
{{- define "generic.fullComponentName" }}
{{- include "generic.appName" . }}
{{- if and .generic.componentName (ne .generic.componentName "_") -}}
-{{ .generic.componentName }}
{{- end }}
{{- end }}

{{/*
Expand the full name of the resource.
*/}}
{{- define "generic.fullResourceName" }}
{{- include "generic.fullComponentName" . }}
{{- if and .generic.resourceName (ne .generic.resourceName "_") -}}
-{{ .generic.resourceName }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "generic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "generic.appName" . }}
app.kubernetes.io/instance: {{ include "generic.appInstance" . }}
{{- if and .generic.componentName (ne .generic.componentName "_") }}
app.kubernetes.io/component: {{ .generic.componentName }}
{{- end }}
{{- if and .generic.resourceName (ne .generic.resourceName "_") }}
component.resource: {{ .generic.resourceName }}
{{- end }}
{{- end }}

{{/*
Resource labels
*/}}
{{- define "generic.resourceLabels" -}}
app.kubernetes.io/managed-by: {{ .helm.Release.Service }}
helm.sh/chart: {{ include "generic.fullChartName" . }}
{{ include "generic.selectorLabels" . }}
{{- if (.helm.Values.app).partOf }}
app.kubernetes.io/part-of: {{ (.helm.Values.app).partOf }}
{{- end }}
{{- if (.helm.Values.app).version }}
app.kubernetes.io/version: {{ (.helm.Values.app).version }}
{{- end }}
{{- if (.helm.Values.app).environment }}
app.environment: {{ (.helm.Values.app).environment }}
{{- end }}
{{- end }}

{{/*
Merge templates from "useTemplates"
*/}}
{{- define "generic.useTemplates" -}}
{{- if .resource.useTemplates }}
  {{- range $templateName := reverse .resource.useTemplates }}
    {{- $_ := merge $.resource (deepCopy (get $.helm.Values.templates $templateName)) }}
  {{- end }}
{{- end }}
{{- end }}
