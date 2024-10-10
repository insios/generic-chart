{{/*
Process object's keys
*/}}
{{- define "generic.processKeys" -}}
{{- $args := first .generic.callStack }}
{{- include "generic.mergeSnippets" . }}
{{- if not (include "generic.isDisabled" .) }}
{{- range $key, $value := $args.obj }}

  {{- if hasPrefix "$" $key }}
    {{- $_ := set $.generic "callStack" (prepend $.generic.callStack (dict
      "obj" $args.obj
      "srcKey" $key
    )) }}
    {{- include "generic.includeTemplate" $ }}
    {{- $_ := unset $args.obj $key }}
    {{- $_ := set $.generic "callStack" (rest $.generic.callStack) }}
  {{- end }}

  {{- if kindIs "map" $value }}

    {{- $_ := set $.generic "callStack" (prepend $.generic.callStack (dict
      "obj" $value
    )) }}
    {{- include "generic.processKeys" $ }}
    {{- if include "generic.isDisabled" $ }}
      {{- $_ := unset $args.obj $key }}
    {{- end }}
    {{- $_ := set $.generic "callStack" (rest $.generic.callStack) }}
    
  {{- else if kindIs "slice" $value }}

    {{- $disabled := list }}
    {{- range $index, $item := $value }}
      {{- if kindIs "map" $item }}
        {{- $_ := set $.generic "callStack" (prepend $.generic.callStack (dict
          "obj" $item
        )) }}
        {{- include "generic.processKeys" $ }}
        {{- if include "generic.isDisabled" $ }}
          {{- $disabled = append $disabled $index }}
        {{- end }}
        {{- $_ := set $.generic "callStack" (rest $.generic.callStack) }}
      {{- end }}
    {{- end }}
    {{- if $disabled }}
      {{- $enabled := list }}
      {{- range $index, $item := $value }}
        {{- if not (has $index $disabled) }}
          {{- $enabled = append $enabled $item }}
        {{- end }}
      {{- end }}
      {{- $_ := set $args.obj $key $enabled }}
    {{- end }}

  {{- end }}

{{- end }}
{{- end }}
{{- end }}

{{/*
Is object disabled
*/}}
{{- define "generic.isDisabled" -}}
{{- $args := first .generic.callStack }}
{{- if hasKey $args.obj "$disabled" }}
  {{- $disabled := get $args.obj "$disabled" }}
  {{- if and (kindIs "string" $disabled) (hasPrefix "{{" $disabled) }}
    {{- $disabled = tpl $disabled . }}
    {{- $disabled = not (or (not $disabled) (eq "0" $disabled) (eq "false" $disabled)) -}}
  {{- end }}
  {{- if $disabled -}}
    true
  {{- else }}
    {{- $_ := unset $args.obj "$disabled" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Merge snippets
*/}}
{{- define "generic.mergeSnippets" -}}
{{- $args := first .generic.callStack }}
{{- if hasKey $args.obj "$snippets" }}
  {{- range $snippetName := reverse (get $args.obj "$snippets") }}
    {{- if kindIs "map" $snippetName }}
      {{- $dummy := $snippetName }}
      {{- $_ := set $.generic "callStack" (prepend $.generic.callStack (dict
        "obj" $dummy
      )) }}
      {{- if include "generic.isDisabled" $ }}
        {{- $snippetName = "" }}
      {{- else }}
        {{- $snippetName = $dummy.snippetName }}
      {{- end }}
      {{- $_ := set $.generic "callStack" (rest $.generic.callStack) }}
    {{- end }}
    {{- if $snippetName }}
      {{- $_ := merge $args.obj (deepCopy (get $.Values.snippets $snippetName)) }}
    {{- end }}
  {{- end }}
  {{- $_ := unset $args.obj "$snippets" }}
{{- end }}
{{- end }}

{{/*
Include generic template
*/}}
{{- define "generic.includeTemplate" -}}
{{- $args := first .generic.callStack }}
{{- $srcKey := $args.srcKey }}
{{- $dstKey := trimPrefix "$" $srcKey }}
{{- $tplName := get $args.obj $srcKey }}
{{- $tplParam := "" }}
{{- $valType := "" }}
{{- $addEmpty := false }}
{{- if kindIs "map" $tplName }}
  {{- $dummy := $tplName }}
  {{- $_ := set $.generic "callStack" (prepend $.generic.callStack (dict
    "obj" $dummy
  )) }}
  {{- if include "generic.isDisabled" $ }}
    {{- $tplName = "" }}
  {{- else }}
    {{- $tplName = $dummy.tplName }}
    {{- $dstKey = default $dstKey $dummy.dstKey }}
    {{- $tplParam = default $tplParam $dummy.tplParam }}
    {{- $valType = default $valType $dummy.valType }}
    {{- $addEmpty = and (hasKey $dummy "addEmpty") $dummy.addEmpty }}
  {{- end }}
  {{- $_ := set $.generic "callStack" (rest $.generic.callStack) }}
{{- else if contains ":" $tplName }}
  {{- $dummy := fromYaml $tplName }}
  {{- $tplName = first (keys $dummy) }}
  {{- $tplParam = first (values $dummy) }}
{{- end }}
{{- if $tplName }}

  {{- if not $valType }}
    {{- $valType = trunc -3 $tplName }}
  {{- end }}

  {{- $_ := set $.generic "callStack" (prepend $.generic.callStack (dict
    "obj" $args.obj
    "srcKey" $srcKey
    "dstKey" $dstKey
    "tplParam" $tplParam
    "valType" $valType
    "addEmpty" $addEmpty
  )) }}
  {{- $value := include (print "generic." $tplName) $ }}
  {{- $_ := set $.generic "callStack" (rest $.generic.callStack) }}

  {{- if eq "Int" $valType }}
    {{- $value = atoi $value }}
    {{- $addEmpty = true }}
  {{- else if eq "Flt" $valType }}
    {{- $value = float64 $value }}
    {{- $addEmpty = true }}
  {{- else if eq "Bln" $valType }}
    {{- $value = not (or (not $value) (eq "0" $value) (eq "false" $value)) }}
    {{- $addEmpty = true }}
  {{- else if eq "Map" $valType }}
    {{- $value = merge (default (dict) (get $args.obj $dstKey)) (fromYaml $value) }}
  {{- else if eq "Lst" $valType }}
    {{- $value = concat (default (list) (get $args.obj $dstKey)) (fromYamlArray $value) }}
  {{- end }}

  {{- if or $value $addEmpty }}
    {{- $_ := set $args.obj $dstKey $value }}
  {{- end }}

{{- end }}
{{- end }}

{{/*
tpl: String
*/}}
{{- define "generic.tplStr" -}}
{{- $args := first .generic.callStack }}
{{- tpl $args.tplParam . }}
{{- end }}

{{/*
tpl: Integer
*/}}
{{- define "generic.tplInt" -}}
{{- atoi (include "generic.tplStr" .) }}
{{- end }}

{{/*
tpl: Float
*/}}
{{- define "generic.tplFlt" -}}
{{- float64 (include "generic.tplStr" .) }}
{{- end }}

{{/*
tpl: Boolean
*/}}
{{- define "generic.tplBln" -}}
{{- $value := include "generic.tplStr" . }}
{{- if or (not $value) (eq "0" $value) (eq "false" $value) }}false{{ else }}true{{ end -}}
{{- end }}

{{/*
tpl: Map
*/}}
{{- define "generic.tplMap" -}}
{{- $args := first .generic.callStack }}
{{- tpl (print (trimSuffix "}}" $args.tplParam) " | toYaml }}") . }}
{{- end }}

{{/*
tpl: List
*/}}
{{- define "generic.tplLst" -}}
{{- include "generic.tplMap" . }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "generic.fullChartNameStr" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the app.
*/}}
{{- define "generic.appNameStr" -}}
{{- default .Release.Name (.Values.app).name }}
{{- end }}

{{/*
Expand the instance of the app.
*/}}
{{- define "generic.appInstanceStr" -}}
{{- default .Release.Name (.Values.app).instance }}
{{- end }}

{{/*
Expand the full name of the component.
*/}}
{{- define "generic.fullComponentNameStr" }}
{{- $args := first .generic.callStack }}
{{- $componentName := .generic.ctx.componentName }}
{{- $param := $args.tplParam }}
{{- if and (kindIs "slice" $param) (eq (len $param) 2) }}
  {{- $componentName = last $param }}
{{- end }}
{{- include "generic.appInstanceStr" . -}}
{{- if $componentName }}-{{ $componentName }}{{ end -}}
{{- end }}

{{/*
Expand the full name of the resource.
*/}}
{{- define "generic.fullResourceNameStr" }}
{{- $args := first .generic.callStack }}
{{- $resourceName := .generic.ctx.resourceName }}
{{- $param := $args.tplParam }}
{{- if and (kindIs "slice" $param) $param }}
  {{- $resourceName = first $param }}
{{- end }}
{{- include "generic.fullComponentNameStr" . -}}
{{- if $resourceName }}-{{ $resourceName }}{{ end -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "generic.selectorLabelsMap" -}}
{{- $args := first .generic.callStack }}
{{- $resourceName := .generic.ctx.resourceName }}
{{- $componentName := .generic.ctx.componentName }}
{{- $param := $args.tplParam }}
{{- if and (kindIs "slice" $param) $param }}
  {{- $resourceName = first $param }}
  {{- if eq (len $param) 2 }}
    {{- $componentName = last $param }}
  {{- end }}
{{- end }}
app.kubernetes.io/name: {{ include "generic.appNameStr" . }}
app.kubernetes.io/instance: {{ include "generic.appInstanceStr" . }}
{{- if $componentName }}
app.kubernetes.io/component: {{ $componentName }}
{{- end }}
{{- if $resourceName }}
component.resource: {{ $resourceName }}
{{- end }}
{{- end }}

{{/*
Resource labels
*/}}
{{- define "generic.resourceLabelsMap" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "generic.fullChartNameStr" . }}
{{ include "generic.selectorLabelsMap" . }}
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
