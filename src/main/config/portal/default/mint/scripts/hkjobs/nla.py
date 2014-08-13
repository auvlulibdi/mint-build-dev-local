from com.googlecode.fascinator.api.indexer import SearchRequest
from com.googlecode.fascinator.common import JsonObject
from com.googlecode.fascinator.common.messaging import MessagingServices
from com.googlecode.fascinator.common.solr import SolrResult
from com.googlecode.fascinator.messaging import TransactionManagerQueueConsumer
from com.googlecode.fascinator.redbox.sru import SRUClient

from java.io import ByteArrayInputStream
from java.io import ByteArrayOutputStream
from java.lang import Exception

class NlaData:
    def __init__(self):
        self.messaging = MessagingServices.getInstance()

    def __activate__(self, context):
        self.vc = context
        self.log      = self.vc["log"]
        self.services = self.vc["Services"]
        self.writer   = self.vc["response"].getPrintWriter("text/html; charset=UTF-8")
        # We check config now for how to store this
        self.config   = self.vc["systemConfig"]
        self.nlaProperty = self.config.getString("nlaPid", ["curation", "nlaIntegration", "pidProperty"])

        self.process()

    def process(self):
        self.log.debug("NLA housekeeping executing")

        # Find solr records
        result = self.search_solr()
        #self.log.debug('-----start debuging result----')
        #self.log.debug(result.toString())
        #self.log.debug('----- end of debuging -----')
        if result is None:
            return

        # Is there any work to do?
        num = result.getNumFound()
        if num == 0:
            self.writer.println("No records to process")
            self.writer.close()
            return
        else: 
            self.log.debug("Processing '{}' records", num)

        # Now loop through each object and process
        sru = SRUClient()
        # If using the NLA's test server, comment out the line above and uncomment the line below
        # sru = SRUClient("http://www-test.nla.gov.au/apps/srw/search/peopleaustralia")

        for record in result.getResults():
            #self.log.debug("**** start to debug each record **** ")
            #self.log.debug(record.toString())
            #self.log.debug("*** end of debug ****")
            success = self.process_record(record, sru)
            if not success:
                self.log.debug("Failed to process record")
                continue
            else:
               self.log.debug("Record processed")

        self.writer.println("%s record(s) processed" % num)
        self.writer.close()

    # Process an individual record
    def process_record(self, record, sru):
        try:
            # id = record.getFirst("storage_id")
            id = record.getFirst("ID")

            # id = record.getFirst("dc_identifier")
            #self.log.debug( "DC.Identifier is {} :::", [id])
            pid = record.getFirst("pidProperty")
            sid = record.getFirst("storage_id")

            # self.log.debug("cja:id (should contain ID): '{}'", id)
            # self.log.debug("cja:pid: '{}'", pid)

            # self.log.debug(pid)
            # self.log.debug(record.__dict__)

            # TODO
            #self.log.info("*** Begin Test Suite *****")
            #self.log.info("Test n1::: Empty Id :::")
            #nlaPid = sru.nlaGetNationalId("");
            #self.log.debug("NLA ID is :: {} ::", [nlaPid])
            #self.log.info("Test n2::: Storage Id :::")
            #nlaPid = sru.nlaGetNationalId("02abace9-0d5e-4271-96ee-d676c2f45aa2")
            #self.log.debug("NLA ID is :: {} ::", [nlaPid])
            #self.log.info("Test n3::: NLA Id :::")
            #nlaPid = sru.nlaGetNationalId("nla.party-915313");
            #self.log.debug("NLA ID is :: {} ::", [nlaPid])
            #self.log.info("Test n4::: Institl Id :::")
            #nlaPid = sru.nlaGetNationalId("anbd.aut-an35333446");
            #self.log.debug("NLA ID is :: {} ::", [nlaPid])
            #self.log.info("Test n5::: Institl Id :::")
            #nlaPid = sru.nlaGetNationalId("35333446");
            #self.log.debug("NLA ID is :: {} ::", [nlaPid])
            
            #self.log.info("Test n6::: Id :::")
            nlaPid = sru.nlaGetNationalId(id);
            #self.log.debug("NLA ID is :: {} ::", [nlaPid])

            #self.log.info("*** Test Suite Ends ****")

            #nlaPid = sru.nlaGetNationalId("nla.party-915373"); # Debugging. A known NLA ID

            self.log.debug("{} => {} ({})", [id, pid, nlaPid])

            if nlaPid is None:
                self.log.debug("Object '{}' does not yet have a national Identity in NLA", id)
                return False
            else:
                self.log.debug("Object '{}' has a new national Identity in NLA ({})", id, nlaPid)

            # Store the NLA ID locally
            # object = self.services.getStorage().getObject(id)
            object = self.services.getStorage().getObject(sid)
            metadata = object.getMetadata()
            metadata.setProperty(self.nlaProperty, nlaPid)
            object.close()

            # Notify the curation manager
            self.send_message(id)
            return True

        except Exception, e:
            self.log.error("Error updating object: ", e)
            self.throw_error("failure updating object: " + e.getMessage())
            return False

    # Send an event notification
    def send_message(self, oid):
        message = JsonObject()
        message.put("oid", oid)
        message.put("task", "curation-confirm")
        self.messaging.queueMessage(
                TransactionManagerQueueConsumer.LISTENER_ID,
                message.toString())

    # Search solr for objects that we are interested in
    def search_solr(self):
        # Build our solr query
        readyForNla = "ready_for_nla:ready"
        nlaPidExists = "nlaId:http*"
        query = readyForNla + " AND NOT " + nlaPidExists
        # Prepare the query
        req = SearchRequest(query)
        req.setParam("facet", "false")
        req.setParam("rows", "20")
        # Run the query
        try:
            out = ByteArrayOutputStream()
            self.services.getIndexer().search(req, out)
            return SolrResult(ByteArrayInputStream(out.toByteArray()))
        except Exception, e:
            self.log.error("Error searching solr: ", e)
            self.throw_error("failure searching solr: " + e.getMessage())
            return None

    def throw_error(self, message):
        self.vc["response"].setStatus(500)
        self.writer.println("Error: " + message)
        self.writer.close()
