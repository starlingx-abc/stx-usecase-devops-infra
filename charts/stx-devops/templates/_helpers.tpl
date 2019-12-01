{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "stx-devops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stx-devops.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "stx-devops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create ceph pvc for dcpdev
*/}}
{{- define "stx-devops.cephfs-pvc" -}}
{{- $envAll := index . 0 -}}
{{- $_name := index . 1 -}}
{{- $pvc := index $envAll.Values.cephfs_pvc $_name -}}
{{- $name := printf "%s-%s" $envAll.Release.Namespace $_name -}}

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $name -}}-pv
  namespace: {{ $envAll.Release.Namespace }}
spec:
  storageClassName: general
  capacity:
    storage: 4096Gi
  accessModes:
    - ReadWriteMany
  cephfs:
    monitors:
    {{- range $v := $envAll.Values.ceph.monitors }}
    - {{ $v | quote }}
    {{- end }}
    path: /{{- $envAll.Release.Namespace -}}/{{- $pvc.path }}
    readOnly: {{ $pvc.readOnly }}
    user: {{ $envAll.Values.ceph.user }}
    secretRef:
      name: {{ $envAll.Chart.Name }}
      key: ceph-secret
  persistentVolumeReclaimPolicy: Retain

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $name -}}-pvc
  namespace: {{ $envAll.Release.Namespace }}
spec:
  accessModes:
    - ReadWriteMany
  volumeName: {{ $name -}}-pv
  resources:
    requests:
      storage: 4096Gi

{{- end -}}

{{- define "stx-devops.kubernetes-plugin-version" -}}
  {{- range .Values.jenkins.plugins -}}
    {{ if hasPrefix "kubernetes:" . }}
      {{- $split := splitList ":" . }}
      {{- printf "%s" (index $split 1 ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

