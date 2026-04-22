# modules/notebooks/main.tf
# Uploads four Python notebooks into the Databricks workspace under
# /terraform-managed/. Each notebook represents one pipeline layer:
#   01_init        — library installs & Spark config
#   02_ingest      — Bronze: raw data ingestion
#   03_transform   — Silver: cleaning and enrichment
#   04_report      — Gold: aggregation for BI

locals {
  notebook_base_path = "/terraform-managed"

  # Base64-encoded Python notebook source.
  # Re-encode with: base64 -w0 notebook.py
  notebook_init_b64 = "IyBEYXRhYnJpY2tzIG5vdGVib29rIHNvdXJjZQojIE1BR0lDICVtZCAjIyBJbml0IC8gU2V0dXAgTm90ZWJvb2sKCiMgQ09NTUFORCAtLS0tLS0tLS0tCmltcG9ydCBzdWJwcm9jZXNzLCBzeXMKCmRlZiBwaXBfaW5zdGFsbChwa2cpOgogICAgc3VicHJvY2Vzcy5jaGVja19jYWxsKFtzeXMuZXhlY3V0YWJsZSwgJy1tJywgJ3BpcCcsICdpbnN0YWxsJywgJy0tcXVpZXQnLCBwa2ddKQoKcGlwX2luc3RhbGwoJ3B5YXJyb3c+PTEyLjAnKQpwaXBfaW5zdGFsbCgncGFuZGFzPj0yLjAnKQpwcmludCgnTGlicmFyaWVzIGluc3RhbGxlZC4nKQoKIyBDT01NQU5EIC0tLS0tLS0tLS0Kc3BhcmsuY29uZi5zZXQoJ3NwYXJrLmRhdGFicmlja3MuZGVsdGEub3B0aW1pemVXcml0ZS5lbmFibGVkJywgJ3RydWUnKQpzcGFyay5jb25mLnNldCgnc3BhcmsuZGF0YWJyaWNrcy5kZWx0YS5hdXRvQ29tcGFjdC5lbmFibGVkJywgJ3RydWUnKQpwcmludCgnU3Bhcmsgc2Vzc2lvbiBjb25maWd1cmVkLicpCgojIENPTU1BTkQgLS0tLS0tLS0tLQpjYXRhbG9ncyA9IHNwYXJrLnNxbCgnU0hPVyBDQVRBTE9HUycpLmNvbGxlY3QoKQpwcmludCgnQXZhaWxhYmxlIGNhdGFsb2dzOicsIFtjWzBdIGZvciBjIGluIGNhdGFsb2dzXSkK"

  notebook_ingest_b64 = "IyBEYXRhYnJpY2tzIG5vdGVib29rIHNvdXJjZQojIE1BR0lDICVtZCAjIyBEYXRhIEluZ2VzdGlvbiAtLSBCcm9uemUgTGF5ZXIKCiMgQ09NTUFORCAtLS0tLS0tLS0tCmZyb20gcHlzcGFyay5zcWwgaW1wb3J0IGZ1bmN0aW9ucyBhcyBGCmZyb20gcHlzcGFyay5zcWwudHlwZXMgaW1wb3J0IFN0cnVjdFR5cGUsIFN0cnVjdEZpZWxkLCBTdHJpbmdUeXBlLCBJbnRlZ2VyVHlwZSwgVGltZXN0YW1wVHlwZQppbXBvcnQgZGF0ZXRpbWUKClRBUkdFVF9DQVRBTE9HID0gc3BhcmsuY29uZi5nZXQoJ3BpcGVsaW5lLnRhcmdldF9jYXRhbG9nJywgJ2RldicpClRBUkdFVF9UQUJMRSA9IGYne1RBUkdFVF9DQVRBTE9HfS5icm9uemUucmF3X2V2ZW50cycKCnNjaGVtYSA9IFN0cnVjdFR5cGUoWwogICAgU3RydWN0RmllbGQoJ2V2ZW50X2lkJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksCiAgICBTdHJ1Y3RGaWVsZCgnZXZlbnRfdHlwZScsIFN0cmluZ1R5cGUoKSwgVHJ1ZSksCiAgICBTdHJ1Y3RGaWVsZCgndXNlcl9pZCcsIEludGVnZXJUeXBlKCksIFRydWUpLAogICAgU3RydWN0RmllbGQoJ3BheWxvYWQnLCBTdHJpbmdUeXBlKCksIFRydWUpLAogICAgU3RydWN0RmllbGQoJ2NyZWF0ZWRfYXQnLCBUaW1lc3RhbXBUeXBlKCksIFRydWUpLApdKQoKc2FtcGxlX2RhdGEgPSBbCiAgICAoJ2V2dC0wMDEnLCAnY2xpY2snLCAxMDAxLCAnYnV0dG9uPXN1Ym1pdCcsIGRhdGV0aW1lLmRhdGV0aW1lLnV0Y25vdygpKSwKICAgICgnZXZ0LTAwMicsICdwYWdldmlldycsIDEwMDIsICdwYWdlPS9ob21lJywgZGF0ZXRpbWUuZGF0ZXRpbWUudXRjbm93KCkpLAogICAgKCdldnQtMDAzJywgJ3B1cmNoYXNlJywgMTAwMSwgJ2Ftb3VudD00OS45OScsIGRhdGV0aW1lLmRhdGV0aW1lLnV0Y25vdygpKSwKXQoKcmF3X2RmID0gKAogICAgc3BhcmsuY3JlYXRlRGF0YUZyYW1lKHNhbXBsZV9kYXRhLCBzY2hlbWEpCiAgICAgICAgIC53aXRoQ29sdW1uKCdpbmdlc3Rpb25fdHMnLCBGLmN1cnJlbnRfdGltZXN0YW1wKCkpCiAgICAgICAgIC53aXRoQ29sdW1uKCdzb3VyY2VfZmlsZScsIEYubGl0KCdtYW51YWxfc2FtcGxlJykpCikKCnJhd19kZi53cml0ZS5mb3JtYXQoJ2RlbHRhJykubW9kZSgnYXBwZW5kJykub3B0aW9uKCdtZXJnZVNjaGVtYScsICd0cnVlJykuc2F2ZUFzVGFibGUoVEFSR0VUX1RBQkxFKQpwcmludChmJ1dyb3RlIHtyYXdfZGYuY291bnQoKX0gcm93cyB0byB7VEFSR0VUX1RBQkxFfScpCmRpc3BsYXkoc3BhcmsudGFibGUoVEFSR0VUX1RBQkxFKS5saW1pdCgxMCkpCg=="

  notebook_transform_b64 = "IyBEYXRhYnJpY2tzIG5vdGVib29rIHNvdXJjZQojIE1BR0lDICVtZCAjIyBEYXRhIFRyYW5zZm9ybWF0aW9uIC0tIFNpbHZlciBMYXllcgoKIyBDT01NQU5EIC0tLS0tLS0tLS0KZnJvbSBweXNwYXJrLnNxbCBpbXBvcnQgZnVuY3Rpb25zIGFzIEYKZnJvbSBkZWx0YS50YWJsZXMgaW1wb3J0IERlbHRhVGFibGUKClRBUkdFVF9DQVRBTE9HID0gc3BhcmsuY29uZi5nZXQoJ3BpcGVsaW5lLnRhcmdldF9jYXRhbG9nJywgJ2RldicpClNPVVJDRV9UQUJMRSA9IGYne1RBUkdFVF9DQVRBTE9HfS5icm9uemUucmF3X2V2ZW50cycKVEFSR0VUX1RBQkxFID0gZid7VEFSR0VUX0NBVEFMT0d9LnNpbHZlci5jbGVhbmVkX2V2ZW50cycKCmJyb256ZV9kZiA9IHNwYXJrLnRhYmxlKFNPVVJDRV9UQUJMRSkKCnNpbHZlcl9kZiA9ICgKICAgIGJyb256ZV9kZgogICAgLmZpbHRlcihGLmNvbCgnZXZlbnRfaWQnKS5pc05vdE51bGwoKSkKICAgIC5maWx0ZXIoRi5jb2woJ2V2ZW50X3R5cGUnKS5pc2luKFsnY2xpY2snLCAncGFnZXZpZXcnLCAncHVyY2hhc2UnXSkpCiAgICAud2l0aENvbHVtbignZXZlbnRfdHlwZScsIEYudXBwZXIoRi5jb2woJ2V2ZW50X3R5cGUnKSkpCiAgICAud2l0aENvbHVtbigncHJvY2Vzc2VkX3RzJywgRi5jdXJyZW50X3RpbWVzdGFtcCgpKQogICAgLndpdGhDb2x1bW4oJ2RhdGVfcGFydGl0aW9uJywgRi50b19kYXRlKEYuY29sKCdjcmVhdGVkX2F0JykpKQogICAgLmRyb3BEdXBsaWNhdGVzKFsnZXZlbnRfaWQnXSkKKQoKaWYgc3BhcmsuY2F0YWxvZy50YWJsZUV4aXN0cyhUQVJHRVRfVEFCTEUpOgogICAgdGFyZ2V0ID0gRGVsdGFUYWJsZS5mb3JOYW1lKHNwYXJrLCBUQVJHRVRfVEFCTEUpCiAgICAodGFyZ2V0LmFsaWFzKCd0JykKICAgICAgICAgICAubWVyZ2Uoc2lsdmVyX2RmLmFsaWFzKCdzJyksICd0LmV2ZW50X2lkID0gcy5ldmVudF9pZCcpCiAgICAgICAgICAgLndoZW5NYXRjaGVkVXBkYXRlQWxsKCkKICAgICAgICAgICAud2hlbk5vdE1hdGNoZWRJbnNlcnRBbGwoKQogICAgICAgICAgIC5leGVjdXRlKCkpCmVsc2U6CiAgICAoc2lsdmVyX2RmLndyaXRlCiAgICAgICAgICAgICAgLmZvcm1hdCgnZGVsdGEnKQogICAgICAgICAgICAgIC5tb2RlKCdvdmVyd3JpdGUnKQogICAgICAgICAgICAgIC5wYXJ0aXRpb25CeSgnZGF0ZV9wYXJ0aXRpb24nKQogICAgICAgICAgICAgIC5zYXZlQXNUYWJsZShUQVJHRVRfVEFCTEUpKQoKcHJpbnQoZidTaWx2ZXIgdGFibGUge1RBUkdFVF9UQUJMRX0gdXBkYXRlZC4nKQpkaXNwbGF5KHNwYXJrLnRhYmxlKFRBUkdFVF9UQUJMRSkubGltaXQoMTApKQo="

  notebook_report_b64 = "IyBEYXRhYnJpY2tzIG5vdGVib29rIHNvdXJjZQojIE1BR0lDICVtZCAjIyBSZXBvcnRpbmcgLS0gR29sZCBMYXllcgoKIyBDT01NQU5EIC0tLS0tLS0tLS0KZnJvbSBweXNwYXJrLnNxbCBpbXBvcnQgZnVuY3Rpb25zIGFzIEYKClRBUkdFVF9DQVRBTE9HID0gc3BhcmsuY29uZi5nZXQoJ3BpcGVsaW5lLnRhcmdldF9jYXRhbG9nJywgJ2RldicpClNPVVJDRV9UQUJMRSA9IGYne1RBUkdFVF9DQVRBTE9HfS5zaWx2ZXIuY2xlYW5lZF9ldmVudHMnClRBUkdFVF9UQUJMRSA9IGYne1RBUkdFVF9DQVRBTE9HfS5nb2xkLmV2ZW50X3N1bW1hcnknCgpzaWx2ZXJfZGYgPSBzcGFyay50YWJsZShTT1VSQ0VfVEFCTEUpCgpnb2xkX2RmID0gKAogICAgc2lsdmVyX2RmCiAgICAuZ3JvdXBCeSgnZGF0ZV9wYXJ0aXRpb24nLCAnZXZlbnRfdHlwZScpCiAgICAuYWdnKAogICAgICAgIEYuY291bnQoJ2V2ZW50X2lkJykuYWxpYXMoJ2V2ZW50X2NvdW50JyksCiAgICAgICAgRi5jb3VudERpc3RpbmN0KCd1c2VyX2lkJykuYWxpYXMoJ3VuaXF1ZV91c2VycycpLAogICAgICAgIEYubWF4KCdwcm9jZXNzZWRfdHMnKS5hbGlhcygnbGFzdF9wcm9jZXNzZWRfdHMnKSwKICAgICkKICAgIC53aXRoQ29sdW1uKCdyZXBvcnRfdHMnLCBGLmN1cnJlbnRfdGltZXN0YW1wKCkpCikKCmdvbGRfZGYud3JpdGUuZm9ybWF0KCdkZWx0YScpLm1vZGUoJ292ZXJ3cml0ZScpLm9wdGlvbignb3ZlcndyaXRlU2NoZW1hJywgJ3RydWUnKS5zYXZlQXNUYWJsZShUQVJHRVRfVEFCTEUpCnByaW50KGYnR29sZCB0YWJsZSB7VEFSR0VUX1RBQkxFfSByZWZyZXNoZWQuJykKZGlzcGxheShzcGFyay50YWJsZShUQVJHRVRfVEFCTEUpLm9yZGVyQnkoJ2RhdGVfcGFydGl0aW9uJywgJ2V2ZW50X3R5cGUnKSkK"
}

# ---------------------------------------------------------------------------
# 01 — Init / Setup notebook
# Installs libraries and configures Spark settings.
# ---------------------------------------------------------------------------
resource "databricks_notebook" "init" {
  path     = "${local.notebook_base_path}/01_init"
  language = "PYTHON"

  # Inline base64-encoded Python source
  content_base64 = local.notebook_init_b64
}

# ---------------------------------------------------------------------------
# 02 — Data Ingestion notebook (Bronze layer)
# Simulates reading raw events and appending them to a Delta table.
# ---------------------------------------------------------------------------
resource "databricks_notebook" "ingest" {
  path     = "${local.notebook_base_path}/02_ingest_bronze"
  language = "PYTHON"

  content_base64 = local.notebook_ingest_b64
}

# ---------------------------------------------------------------------------
# 03 — Data Transformation notebook (Silver layer)
# Cleans Bronze data using Delta MERGE for idempotent upserts.
# ---------------------------------------------------------------------------
resource "databricks_notebook" "transform" {
  path     = "${local.notebook_base_path}/03_transform_silver"
  language = "PYTHON"

  content_base64 = local.notebook_transform_b64
}

# ---------------------------------------------------------------------------
# 04 — Reporting notebook (Gold layer)
# Aggregates Silver data into a Gold summary table for BI.
# ---------------------------------------------------------------------------
resource "databricks_notebook" "report" {
  path     = "${local.notebook_base_path}/04_report_gold"
  language = "PYTHON"

  content_base64 = local.notebook_report_b64
}
