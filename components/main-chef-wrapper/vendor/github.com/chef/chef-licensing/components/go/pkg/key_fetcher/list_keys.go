package keyfetcher

import (
	"fmt"
	"log"
	"time"

	"github.com/chef/chef-licensing/components/go/pkg/api"
	"github.com/gookit/color"
)

func PrintLicenseKeyOverview(keys []string) {
	describe, _ := api.GetClient().GetLicenseDescribe(keys)
	var validity string

	for _, license := range describe.Licenses {
		validity = calculateValidity(license)
		color.Printf("\n------------------------------------------------------------\n")
		color.Bold.Println("License Details")
		format := "%-15s : %-20s\n"
		if len(license.Limits) > 0 {
			color.Printf(format, "Asset Name", license.Limits[0].Software)
		}
		color.Printf(format, "License ID", license.LicenseKey)
		color.Printf(format, "Type", license.LicenseType)
		color.Printf(format, "Status", license.Status)
		color.Printf(format, "Validity", validity)

		color.Printf(format, "No. Of Units", calculateUnits(license))
		color.Printf("------------------------------------------------------------")
	}

}

func calculateValidity(license api.LicenseDetail) (validity string) {
	if license.LicenseType == "free" {
		validity = "Unlimited"
	} else {
		expiresOn, err := time.Parse(time.RFC3339, license.End)
		if err != nil {
			log.Fatal("Unknown expiration time received from the server: ", err)
		}

		expirationIn := int(time.Until(expiresOn).Hours() / 24)
		validity = fmt.Sprintf("%d Day", expirationIn)
		if expirationIn > 1 {
			validity += "s"
		}
	}

	return
}

func calculateUnits(license api.LicenseDetail) (units string) {
	if len(license.Limits) == 0 {
		units = ""
	} else {
		limit := license.Limits[0].Amount
		if limit == -1 {
			units = "Unlimited Units"
		} else {
			units = fmt.Sprintf("%d Units", limit)
		}
	}
	return
}
