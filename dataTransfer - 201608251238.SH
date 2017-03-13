CONN="iot_appaa/iot_app@kfce"
DMPFILE="/home/oracle/EXP20160712.dmp"
LOGFILE="/home/oracle/DMP20160712.LOG"
sqlplus $CONN<< !
create table TD_EC_CUSTOMER as  
SELECT ec.custid,
       cut.custname,
       ec.industryid as INDUSTRY,
       cut.postcode,
       ec.FAX,
       ec.corptype as CORPTYPE,
       ec.Applicationarea as APPLICATIONAREA,
       ec.corplevel as CORPLEVEL,
       ec.ecareaid as ECAREA,
       cut.phone,
       cut.email,
       cut.addr,
       cut.status,
       cut.createdate,
       ec.CUSTOMERRANKID,
       'QW' sourcedb
  FROM CM_CU_ECUSTOMER ec, cm_cu_customer cut, (select distinct appproviderid  from APP_INFO_PLAT)  app
 where ec.custid = cut.custid
   and ec.custid = app.appproviderid;
exit;
!
echo "create table TD_APP_INFO_PLAT"
sqlplus $CONN<< !
create table TD_APP_INFO_PLAT as  SELECT 
       t.APPID,
       t.APPNAME,
       t.APPPROVIDERID,
       t.status,
       t.APPTYPE,
       t.SERVICETYPE,
       cust.CUSTNAME,
       par.mpname               as BELONGSISP,
       t.VASPSIGNATURE,
       t.ACCOUNTNO,
       ac.ACCOUNTNAME,
       t.PROVINCEID             as PROVINCENAME,
       t.PROVINCEID,
       t.LINKMAN,
       t.TELEPHONE,
       t.HTTPCLIENTIP,
       t.HTTPCLIENTPWD,
       ''      as HTTPCLIENTADDRESS,
       t.SMS_RECEIVE_NUMBER SMS_RECEIVE_NUMBER,
       t.VASPID,
       t.VASID,
       t.SMSCLIENTIP,
       t.SMSFLOW,
       t.SMSUSERNAME,
       t.SMSPASSWORD,
       t.MAXITEMPERDAY,
       t.MAXITEMPERMON,
       t.INVALIDTIMESPAN1_START as INVALIDTIMESPAN1START,
       t.INVALIDTIMESPAN1_END   as INVALIDTIMESPAN1END,
       t.APPURL,
       t.APPIP,
       t.APPPORT,
       t.WMMPUSERNAME,
       t.WMMPPASSWORD,
       t.TMHEARTBEAT_CIRCLE     as TMHEARTBEATCIRCLE,
       t.COMMLINKCHECKCYC,
       t.DATAPACKACKCHECKCYC,
       t.TRANSFAILUREMAXRETRANS,
       t.ENCRYPTTYPE,
       t.BASEKEY,
       t.BASEKEY_INVALIDDATE    as BASEKEYINVALIDDATE,
       t.addmultiplelimit,
       t.delpercentum,
       t.httpaccesstype,
       'QW' sourcedb
  FROM APP_INFO_PLAT   t,
       cm_cu_ecaccount ac,
       cm_cu_customer  cust,
       cm_cu_partner   par
 where t.ACCOUNTNO = ac.accountno(+)
   and ac.custid = cust.custid(+)
   and t.appproviderid = par.mpcode(+);
exit;
!
echo "create table TD_API_EB_INFO"
sqlplus $CONN<< !
create table TD_API_EB_INFO as
SELECT t.APIEBID
,t.APICODE
,t.APINAME
,t.APIDES
,t.APIURL
,t.APIMSG
,t.APINOTE
,t.APIBELONGEC
,t.APIBELONGNET
,t.APITYPE
,t.apiepid as EPID
,ep.EPNAME
,t.APISTATUS
,t.CREATEDATE
,'QW' sourcedb
 FROM eb_info_apply_new t,eb_info_provider ep
 where t.apiepid = ep.epid(+);
exit;
!
echo "create table TD_SUBS_ENABLER"
sqlplus $CONN<< !
create table TD_SUBS_ENABLER 
 as SELECT t.APPID
,app.APPNAME
,t.EBID
,eb.apiname as EBNAME
,t.ISUSEWHITELIST
,t.TARIFFID
,tariff.name TARIFFNAME
,t.TARIFFDISCOUNT
,t.PERIODCOUNT
,t.TESTSTARTDATE
,t.TESTENDDATE
,t.STARTDATE
,t.ENDDATE
,t.STATUS
,t.SYNCSTATUS
,t.AUDITDATE
,t.usageamount
,t.periodamount
,'QW' sourcedb
 FROM eb_subs_enabler_new t, app_info_plat app,pc_tariff tariff,eb_info_apply_new eb
 where t.ebid = eb.apiebid(+) and t.appid = app.appid(+) and t.tariffid = tariff.id(+);
exit;
!
echo "create table TD_EC_ACCOUNT"
sqlplus $CONN<< !
create table TD_EC_ACCOUNT as SELECT t.ACCOUNTNO
,t.ACCOUNTNAME
,t.STATUS
,t.CUSTID
,cust.custname as CUSTNAME
,t.CREATETIME
,t.BANKCODE
,t.BANKREGISTERED
,t.BANKACCTNAME
,t.BANKACCTNO
,t.DEPOSIT
,'QW' sourcedb
 FROM cm_cu_ecaccount t,cm_cu_ecustomer ec,cm_cu_customer cust
 where t.custid = ec.custid and ec.custid = cust.custid;
exit;
!
echo "create table TD_EB_PROVIDER"
sqlplus $CONN<< !
create table TD_EB_PROVIDER as SELECT EPID
,EPNAME
,CONTACTMAN
,CONTACTPHONE
,SERVICETEL
,PRINCIPAL
,PCERTYPE
,PCERTID
,HELPINFO
,REWARDPLAN
,SERVICEDESC
,STATUS
,CREATEDATE
,SYNCSTATUS
,'QW' sourcedb
 FROM eb_info_provider;
exit;
!
echo "create table TD_EB_WHITELIST"
sqlplus $CONN<< !
create table TD_EB_WHITELIST as SELECT 
t.ebid apiebid
,eb.APICODE
,eb.APINAME
,t.APPID
,app.APPNAME
,app.apptype as APPTYPE
,sub.ECCUSTID AS CUSTID
,cust.custname as CUSTNAME
,ep.epname
,t.MSISDN
,sub.iccid
,sub.imsi
,t.CREATETIME
,'QW' sourcedb
FROM eb_subs_whitelist_new t,eb_info_apply_new eb,cm_cu_customer cust,CM_SUBS_SUBSCRIBER sub,app_info_plat app,eb_info_provider ep
where t.ebid = eb.apiebid and t.msisdn = sub.msisdn and sub.eccustid=cust.custid and t.appid = app.appid and ep.epid = eb.apiepid;
exit;
!
exp userid=$CONN file=$DMPFILE TABLES=TD_EB_WHITELIST,TD_EB_PROVIDER,TD_EC_ACCOUNT,TD_SUBS_ENABLER,TD_API_EB_INFO,TD_APP_INFO_PLAT,TD_EC_CUSTOMER,API_PARAM_CHECK_INFO,SA_DB_PROVINCE log=$LOGFILE
sqlplus $CONN<< !
drop table TD_EB_WHITELIST;
drop table TD_EB_PROVIDER;
drop table TD_EC_ACCOUNT;
drop table TD_SUBS_ENABLER;
drop table TD_API_EB_INFO;
drop table TD_APP_INFO_PLAT;
drop table TD_EC_CUSTOMER;
exit;
!