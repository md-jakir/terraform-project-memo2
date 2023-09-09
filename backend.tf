terraform {
  cloud {
    organization = "demo-dms-redshift-migration-test"

    workspaces {
      name = "demo-redshift-dms"
    }
  }
}
