# cogux — Requirements (SSoT)

> 단일 진실. 게이트는 이 표의 각 R을 종료 코드로 검증한다.

| id | requirement | gate |
|---|---|---|
| R1 | SKILL.md 에 이름, 한국어·영어 트리거, 6단계 워크플로우, 제외한 원칙 규정, (assumed) 규정, 통합 워크플로우 링크, 필수 게이트 언급이 있다 | cogux_skill_gate.sh |
| R2 | 원칙 파일마다 이름·정의·출처 URL·적용할 때·적용하지 않을 때·관찰 확인이 있고 색인에 실린다 | cogux_refs_gate.sh |
| R3 | 대조되는 예시 프로젝트 둘이 실제 COGUX.md 와 수정된 화면 코드를 갖고, 선택한 원칙이 서로 다르며 이유가 근거 번호에 묶인다 | cogux_fixtures_gate.sh |
| R4 | 예시 화면 코드에 좌측 색 막대가 없다 | no_vertical_stripe_gate.sh |
| R5 | 있어야 할 산출물 개수를 실측한다 | count_gate.sh |
| R6 | 스킬 폴더에 비밀값이 없다 | secrets_gate.sh |
| R7 | 모든 R행이 실존 검증수단에 연결된다 | req_coverage_gate.sh |
| R8 | 선택이 새 프로젝트에 옳은지, 원칙 요약이 출처와 맞는지는 사람이 판단한다 | human |
