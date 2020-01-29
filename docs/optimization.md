# 성능 최적화 정리
## 경험해본 것
- 분산 환경 서버 구축
- DB의 Writer, Reader 분산
- Cache와 DB 분리
- slow query 튜닝(sql, table 분리 등)
- Disk I/O를 줄이기 위해 불필요한 log 끄기
- Polling 구조를 event 구조로 변경 

## 알고있는것 
- 메모리 스와핑을 필요에 따라 줄이거나 늘리기
- Disk/IO를 줄이기 위해 파일 캐시 사용하기
- 웹서버의 thread 갯수 늘리기
