import json, os, sys
from kafka import KafkaProducer
from datetime import datetime
#"C:\Program Files\Python39\Scripts\pip.exe" install --index-url="http://mirror.ru/pypi/simple/" requests kafka_unit --user --trusted-host mirror.ru
# Config JSON: 
#   {
#   	"MAIN": {
#   		"brokers": [
#   			"broker1:9093",
#   			"broker2:9093"
#   		],
#   		"cert_client": "cert_client.pem",
#   		"cert_key": "cert_key.key",
#   		"cert_trust": "cert_trust.pem"
#   	}
#   }

########################################################################################################################
def get_config(filename=''):
    try:
        with open(filename) as conffile:
            return json.load(conffile)
    except Exception as e:
        add_to_log('Error when get config. Error: ' + str(e))
        exit(125)

########################################################################################################################



def add_to_log(datastr, logname='send_data_kafka.log', mode="a"):
    txt = str(datastr)
    with open(os.path.join('log', '' + logname) , mode) as logfile:
        logfile.write(txt + '\n')
        logfile.close()
    return 0


def kafka_send_data(data_json_array=[], brokerscluster='', topic='solr_collections', brocker='', dump2file=False):
    brokers_list = get_config('kafka.conf.json')

    if brokerscluster == '' and brocker == '':
        print('\tError. Var brokerscluster or brocker  not set.')
        return False

    if brocker == '':
        brocker = brokers_list[brokerscluster]['brokers']


    # SSL
    try:
        producer = KafkaProducer(
            security_protocol='SSL',
            ssl_cafile=os.path.join('ssl', brokers_list[brokerscluster]['cert_trust']),
            ssl_certfile=os.path.join('ssl', brokers_list[brokerscluster]['cert_client']),
            ssl_keyfile=os.path.join('ssl', brokers_list[brokerscluster]['cert_key']),
            ssl_check_hostname=False,
            bootstrap_servers=brocker,
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
                                 )
    except Exception as e:
        print('\t#Error. When send to Kafka: ', e)
        exit(1)
    #no SSL
    # producer = KafkaProducer(security_protocol="SSL",
    #                         bootstrap_servers=brokers_list['MAIN'],
    #                          value_serializer=lambda x:
    #                          dumps(x).encode('utf-8'))

    if sys.version_info[0] == 2:
        timestamp = int(datetime.now().strftime('%s'))*1000
    elif sys.version_info[0] == 3:
        timestamp = int(datetime.now().timestamp())*1000

    i = 0
    error = 0
    for data in data_json_array:
        data['timestamp'] = timestamp
        #if len(data.get('replicaname','')) > 5:
        #     print('AA')
        # data = {'timestamp' : ,
        #         'metric_type': 'collection size',
        #         'metric_name': 'colection name',
        #         'metric_name_val': 'test',
        #         'metric_val_int': 100,
        #         'metric_val_str': ''
        #         }
        try:
            if dump2file:
                add_to_log(datastr=data, mode="a")
            producer.send(topic=topic, value=data)
        except Exception as e:
            print('\t#Error. When send to Kafka: ', e)
            error += 1
            i -= 1

        i += 1
        #sleep(1)

    print('\t# Total send to Kafka: ', str(i))
    if error > 0:
        print('\t# Total errors. When send to Kafka: ', str(error))