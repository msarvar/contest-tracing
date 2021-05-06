terraform-init:
	cd tf-project; terraform init

terraform-plan: terraform-init
	cd tf-project; terraform plan -out tfplan.out

terraform-plan-json: terraform-plan
	cd tf-project; terraform show -json tfplan.out > ../tfplan.json

fetch-regula: terraform-plan-json
	conftest pull -p policy/ github.com/fugue/regula/conftest
	conftest pull -p policy/regula/lib 'github.com/fugue/regula//lib'
	conftest pull -p policy/regula/rules github.com/fugue/regula/rules

setup: fetch-regula
	conftest

