//
// PLEASE NOTE: The Keyspace creation command will need to reflect the topology of your
//              environment. SimpleStrategy is only intended to be used in a single data center test deployment.

CREATE KEYSPACE if not exists rtfap
WITH durable_writes = true
AND replication = {
	'class' : 'SimpleStrategy',
	'replication_factor' : 1
};

// create tables
DROP TABLE IF EXISTS  rtfap.transactions;
CREATE TABLE if not exists rtfap.transactions (
	cc_no text,
	year int,
	month int,
	day int,
	txn_time timestamp,
	amount double,
	cc_provider text,
	country text,
	date_text text,
	hour int,
	items MAP<text, double>,
	location text,
	merchant text,
	min int,
	notes text,
	solr_query text,
	status text,
	tags SET<text>,
	txn_id text,
	user_id text,
	PRIMARY KEY (( cc_no, year, month, day ), txn_time)
) WITH CLUSTERING ORDER BY ( txn_time DESC )
AND default_time_to_live = 86400;

DROP TABLE IF EXISTS  rtfap.hourlyaggregates_bycc;
CREATE TABLE if not exists rtfap.hourlyaggregates_bycc(
    cc_no text,
	hour int,
	total_amount double,
    max_amount double,
	min_amount double,
	total_count bigint,
    PRIMARY KEY ((cc_no, hour))
) WITH default_time_to_live = 86400;

DROP TABLE IF EXISTS  rtfap.dailyaggregates_bycc;
CREATE TABLE if not exists rtfap.dailyaggregates_bycc(
    cc_no text,
	day int,
	total_amount double,
    max_amount double,
	min_amount double,
	total_count bigint,
    PRIMARY KEY ((cc_no, day))
) WITH default_time_to_live = 86400;

DROP TABLE IF EXISTS  rtfap.monthlyaggregates_bycc;
CREATE TABLE if not exists rtfap.monthlyaggregates_bycc(
    cc_no text,
	month int,
	total_amount double,
    max_amount double,
	min_amount double,
	total_count bigint,
    PRIMARY KEY ((cc_no, month))
) WITH default_time_to_live = 86400;

DROP TABLE IF EXISTS  rtfap.yearlyaggregates_bycc;
CREATE TABLE if not exists rtfap.yearlyaggregates_bycc(
    cc_no text,
	year int,
	total_amount double,
    max_amount double,
	min_amount double,
	total_count bigint,
    PRIMARY KEY ((cc_no, year))
) WITH default_time_to_live = 86400;

DROP TABLE IF EXISTS  rtfap.dailytxns_bymerchant;
CREATE TABLE rtfap.dailytxns_bymerchant (
    merchant text,
    day int,
    max_amount double static,
    min_amount double static,
    total_amount double static,
    total_count bigint static,
    cc_no text,
    amount double,
    cc_provider text,
    txn_time timestamp,
    txn_id text,
    items map<text, double>,
    location text,
    notes text,
    status text,
    tags set<text>,
    user_id text,
    PRIMARY KEY ((merchant, day), cc_no)
) WITH CLUSTERING ORDER BY (cc_no ASC) AND default_time_to_live = 86400;

DROP TABLE IF EXISTS  rtfap.txn_count_min;
CREATE TABLE if not exists rtfap.txn_count_min (
	year int,
	month int,
	day int,
	hour int,
	minute int,
  time timestamp,
	approved_rate_hr double,
	approved_rate_min double,
	approved_txn_hr int,
	approved_txn_min int,
	ttl_txn_hr int,
	ttl_txn_min int,
	PRIMARY KEY (( year, month, day, hour, minute ))
) WITH default_time_to_live = 86400;

// Cassandra stress table

DROP TABLE IF EXISTS rtfap.txn_by_cc;
CREATE TABLE if not exists rtfap.txn_by_cc (
cc_no text,
txn_year int,
txn_month int,
txn_day int,
txn_time timestamp,
amount double,
cc_provider text,
location text,
merchant text,
notes text,
status text,
tags set<text>,
txn_id text,
user_id text,
	PRIMARY KEY (( cc_no, txn_year, txn_month, txn_day ), txn_time)
) WITH CLUSTERING ORDER BY ( txn_time DESC )
AND default_time_to_live = 86400;

// banana keyspace and table

CREATE KEYSPACE if not exists banana
WITH durable_writes = true
AND replication = {
	'class' : 'SimpleStrategy',
	'replication_factor' : 1
};

DROP TABLE IF EXISTS banana.dashboards;
CREATE TABLE if not exists banana.dashboards (id text PRIMARY KEY,
"_version_" bigint, dashboard text, group text, solr_query text, title text, user text);


// Sample rtfap.transaction inserts

insert into rtfap.transactions (year, month, day, hour, min, txn_time, cc_no, amount, cc_provider, items, location, merchant, notes, status, txn_id, user_id, tags) VALUES ( 2016, 03, 09, 11, 04, '2016-03-09 11:04:19', '1234123412341234', 200.0, 'VISA', {'tshirt':25, 'dressshirt':50, 'trousers':125}, 'San Francisco', 'Nordstrom', 'pretty good clothing', 'Approved', '098765', 'kunalak', {'Suspicious'});
insert into rtfap.transactions (year, month, day, hour, min, txn_time, cc_no, amount, cc_provider, items, location, merchant, notes, status, txn_id, user_id, tags) VALUES ( 2016, 03, 09, 11, 04, '2016-03-09 11:04:24', '1234123412341235', 400.0, 'VISA', {'cap':25, 'lamps':275, 'trousers':100}, 'San Diego', 'Macy', 'cool stuff-good customer', 'Rejected', '876354', 'simonanbridge', {'Fraudulent'});
insert into rtfap.transactions (year, month, day, hour, min, txn_time, cc_no, amount, cc_provider, items, location, merchant, notes, status, txn_id, user_id, tags) VALUES ( 2016, 03, 09, 11, 04, '2016-03-09 11:04:53', '1234123412341235', 800.0, 'VISA', {'chocolates':300, 'electronics':500}, 'London', 'Harrods', 'customer likes electronics', 'Approved', '982538', 'simonanbridge', {'HighValue'});
insert into rtfap.transactions (year, month, day, hour, min, txn_time, cc_no, amount, cc_provider, items, location, merchant, notes, status, txn_id, user_id, tags) VALUES ( 2016, 03, 09, 11, 04, '2016-03-09 11:04:59', '1234123412341236', 750.0, 'MASTERCARD', {'shoes':300, 'belts':150, 'clothes':300}, 'San Jose', 'GAP', 'customer likes electronics', 'Approved', '092753', 'cary', {'HighValue'});
insert into rtfap.transactions (year, month, day, hour, min, txn_time, cc_no, amount, cc_provider, items, location, merchant, notes, status, txn_id, user_id, tags) VALUES ( 2016, 03, 09, 12, 30, '2016-03-09 12:30:00', '1234123412341237', 1500.0, 'AMEX', {'clothes':1500}, 'New York', 'Ann Taylor', 'frequent customer', 'Approved', '876302', 'caroline', {'HighValue'});
insert into rtfap.transactions (year, month, day, hour, min, txn_time, cc_no, amount, cc_provider, items, location, merchant, notes, status, txn_id, user_id, tags) VALUES ( 2016, 03, 17, 21, 04, '2016-03-17 21:04:19', '1234123412341234', 200.0, 'VISA', {'tshirt':25, 'dressshirt':50, 'trousers':125}, 'San Francisco', 'Nordstrom', 'asked for discounts', 'Approved', '763629', 'kunalak', {'Fraudulent'});
