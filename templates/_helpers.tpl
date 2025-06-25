{{/*
Expand the name of the chart.
*/}}
{{- define "mlflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mlflow.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mlflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mlflow.labels" -}}
helm.sh/chart: {{ include "mlflow.chart" . }}
{{ include "mlflow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mlflow.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mlflow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate OAuth proxy session secret
*/}}
{{- define "mlflow.sessionSecret" -}}
{{- if .Values.mlflow.oauth.sessionSecret }}
{{- .Values.mlflow.oauth.sessionSecret }}
{{- else }}
{{- randAlphaNum 32 | b64enc }}
{{- end }}
{{- end }}

{{/*
Generate OAuth proxy cookie secret
*/}}
{{- define "mlflow.cookieSecret" -}}
{{- if .Values.mlflow.oauth.cookieSecret }}
{{- .Values.mlflow.oauth.cookieSecret }}
{{- else }}
{{- randAlphaNum 32 | b64enc }}
{{- end }}
{{- end }}