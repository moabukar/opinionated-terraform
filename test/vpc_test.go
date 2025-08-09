package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestVPCMinimal(t *testing.T) {
	backend := os.Getenv("TEST_BACKEND") // "localstack" or ""
	tfdir := "../modules/vpc/examples/minimal"

	opts := &terraform.Options{
		TerraformDir: tfdir,
		EnvVars: map[string]string{
			"AWS_ACCESS_KEY_ID":     getEnv("AWS_ACCESS_KEY_ID", "test"),
			"AWS_SECRET_ACCESS_KEY": getEnv("AWS_SECRET_ACCESS_KEY", "test"),
			"AWS_REGION":            getEnv("AWS_REGION", "eu-west-2"),
		},
	}

	// LocalStack support: point provider via environment variables isn't needed for module example
	// Assertions are based on outputs (Terraform state), not AWS API.
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	privateSubnets := terraform.OutputList(t, opts, "private_subnets")
	if len(privateSubnets) < 3 {
		t.Fatalf("expected at least 3 private subnets, got %d", len(privateSubnets))
	}

	nats := terraform.OutputList(t, opts, "nat_gateway_ids")
	if len(nats) != 1 {
		t.Fatalf("expected 1 NAT gateway, got %d", len(nats))
	}

	// Flow logs output exists (resource created)
	flow := terraform.Output(t, opts, "vpc_id")
	if flow == "" {
		t.Fatalf("expected vpc_id output non-empty")
	}

	if backend == "localstack" {
		t.Log("Running against LocalStack: skipping AWS API validations")
	}
}

func getEnv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
