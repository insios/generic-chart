{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "generic.fullChartName" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the app.
*/}}
{{- define "generic.appName" -}}
{{- default .Release.Name (.Values.app).name }}
{{- end }}

{{/*
Expand the instance of the app.
*/}}
{{- define "generic.appInstance" -}}
{{- default .Release.Name (.Values.app).instance }}
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
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "generic.fullChartName" . }}
{{ include "generic.selectorLabels" . }}
{{- if (.Values.app).partOf }}
app.kubernetes.io/part-of: {{ (.Values.app).partOf }}
{{- end }}
{{- if (.Values.app).version }}
app.kubernetes.io/version: {{ (.Values.app).version }}
{{- end }}
{{- if (.Values.app).environment }}
app.environment: {{ (.Values.app).environment }}
{{- end }}
{{- end }}

{{/*
Merge templates from "useTemplates"
*/}}
{{- define "generic.useTemplates" -}}
{{- if .resource.useTemplates }}
  {{- range $templateName := reverse .resource.useTemplates }}
    {{- $_ := merge $.resource (deepCopy (get $.root.Values.templates $templateName)) }}
  {{- end }}
{{- end }}
{{- end }}
