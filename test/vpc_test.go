package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestVPCMinimal(t *testing.T) {
	// test validates terraform outputs (works with LocalStack or AWS)
	opts := &terraform.Options{
		TerraformDir: "../modules/vpc/examples/minimal",
		Upgrade:      true,
		EnvVars: map[string]string{
			"AWS_ACCESS_KEY_ID":     getenv("AWS_ACCESS_KEY_ID", "local"),
			"AWS_SECRET_ACCESS_KEY": getenv("AWS_SECRET_ACCESS_KEY", "local"),
			"AWS_DEFAULT_REGION":    getenv("AWS_DEFAULT_REGION", "eu-west-2"),
			"AWS_ENDPOINT_URL":      os.Getenv("AWS_ENDPOINT_URL"), // LocalStack if set
		},
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	nats := terraform.Output(t, opts, "nat_gateway_count")
	if nats == "" {
		t.Fatalf("expected nat_gateway_count output")
	}
}

func getenv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
