# cogux: 이 저장소에 있는 파일만 호출합니다.
.DEFAULT_GOAL := verify
.PHONY: verify

verify: ## 구조 게이트 실행
	bash gates/verify_cogux.sh .
