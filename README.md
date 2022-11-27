2022 마이스터넷 주관 전국 기능경기대회 - 클라우드 컴퓨팅 종목 1과제 리소스들을 terraform으로 정리해놓은 디렉터리 입니다.

채점시 bastion 서버의 instance Type를 't3.micro' 에서 'c5.large'로 변경합니다. (비용 절감을 목적으로 t3.micro 타입으로 설정해놨습니다.)

키페어는 terraform apply로 배포한 경로에 "skills-keypair.pem"으로 저장됩니다.


추가할 기능 
1. access키 로컬 파일에서 불러오게 구성.
  - terraform apply를 하려면 aws configure 설정이 되어야 하므로.
  - 어떤 환경에서도 동일한 실행결과를 얻게 하기 위함.
  - 로컬파일에서 불로오게 구성 시 파일 경로만 유출되고 파일 내용은 유출되지 않음. (퍼블릭 저장소에 공유 가능)



미구현 기능
/* cluster.tf는 사용하지 않습니다.(주석처리 해놨음)
shell script에서 bastion ec2를 통해 /home/ec2-user/environment/ 경로의 cluster.yaml 파일을 통해
클러스터를 생성합니다/

![initial](https://user-images.githubusercontent.com/78064289/204135085-fe3488c9-4594-4310-8df1-00b9a74cf4f5.png)
