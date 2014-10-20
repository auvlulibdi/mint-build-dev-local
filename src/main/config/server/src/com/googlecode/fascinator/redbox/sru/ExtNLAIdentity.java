package com.googlecode.fascinator.redbox.sru;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.dom4j.Element;
import org.dom4j.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ExtNLAIdentity extends NLAIdentity {

	/** Logging **/
	private static Logger log = LoggerFactory.getLogger(NLAIdentity.class);

	//TODO: add comments
	private static final String NODE_IDENTITY = "eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry";
	private static final String NODE_ALTERNATIVE_SET = "eac:eac-cpf/eac:cpfDescription/eac:alternativeSet";
	private static final String NODES_OTHER_RECORD_IDS = "eac:setComponent/eac:objectXMLWrap/eac:eac-cpf/eac:control/eac:otherRecordId";
	private static final String NODE_FORNAME = "eac:part[(@localType=\"forename\") or (@localType=\"givenname\")]";
	private static final String NODE_FAMILYNAME = "eac:part[(@localType=\"surname\") or (@localType=\"familyname\")]";
	private static final String NODE_EXTENTION = "eac:part[(@localType=\"extension\")]";
	private static final String NODE_TITLE = "eac:part[@localType=\"title\"]";

	/** DOM4J Node for this person **/
	private Node eac;

	/** Properties we extract **/
	private List<Map<String, String>> knownIds;

//	List<String> displayNames = new ArrayList<String>();
	private String additionalInformation;
	private String otherId;
	
	public String getOtherId() {
		return otherId;
	}

	public void setOtherId(String otherId) {
		this.otherId = otherId;
	}

	public String getAdditionalInformation() {
		return additionalInformation;
	}

	public void setAdditionalInformation(String additionalInformation) {
		this.additionalInformation = additionalInformation;
	}

	public ExtNLAIdentity(Node node) throws SRUException {
		super(node);
		eac = node;
		additionalInformation = "AI:";

		// Identity
		knownIds = getSourceIdentities();
		for(Map<String, String> names: knownIds){
			additionalInformation += " ["+ names.get("displayName") +"] ";
		}

		otherId = getOtherIdValue();
	}

	private String getOtherIdValue(){
		String otherIds = "";
		
		Node nlaAltNode = eac.selectSingleNode(NODE_ALTERNATIVE_SET);
		if(nlaAltNode == null) return null;
		
		List<Node> lnode = nlaAltNode.selectNodes(NODES_OTHER_RECORD_IDS);
		for (Node n : lnode){
			String otherId =  n.getText();	
			if (!otherId.startsWith("http://nla.gov.au") ) { 	//Filter!? Do we need nla identity at all? Would it be easier to have only one Id.
				otherIds += " " + otherId;
			}
		}
		
		
		System.out.println(otherIds);
		return otherIds;
	}
	
	private List<Map<String, String>> getSourceIdentities() {
		List<Map<String, String>> nameList = new ArrayList<Map<String, String>>();

		// Any names for this ID
//		Node node = eac.selectSingleNode();
		List<Node> names = eac.selectNodes(NODE_IDENTITY);
		for (Node name : names) {
			String thisDisplay = null; 			// Display Name
			Map<String, String> nameMap = new HashMap<String, String>();

			String thisSurname = getValueFromSingleNodeByName(name, NODE_FAMILYNAME);
			if (thisSurname != null) {
				thisDisplay = thisSurname;
				nameMap.put("surname", thisSurname);
				
				String thisFirstName = getValueFromSingleNodeByName(name, NODE_FORNAME);
				if (thisFirstName != null) {
					thisDisplay += ", " + thisFirstName;
					nameMap.put("firstName", thisFirstName);
				}
				
				String thisExtension = getValueFromSingleNodeByName(name, NODE_EXTENTION);
				if (thisExtension != null) {
					thisDisplay += ", " + thisExtension;
					nameMap.put("extension", thisExtension);
				}
				
				
				String title = getValueFromSingleNodeByName(name, NODE_TITLE);
				if (title != null) {
					thisDisplay += " (" + title + ")";
				}
				nameMap.put("displayName", thisDisplay);
			} else { 
			// if (thisDisplay == null) {				
			// Last ditch effort... we couldn't find simple name information
			// from recommended values. So just concatenate what we can see.

				// Find every part that exists in the XML node
				List<Node> parts = name.selectNodes("eac:part");
				for (Node part : parts) {
					// Grab the value and type of this value
					Element element = (Element) part;
					String value = element.getText();
					String type = element.attributeValue("localType");
					// Build a display value for this part
					if (type != null) {
						value += " (" + type + ")";
					}
					// And add to the display name
					if (thisDisplay == null) {
						thisDisplay = value;
					} else {
						thisDisplay += ", " + value;
					}
				}
				nameMap.put("displayName", thisDisplay);
			}

			nameList.add(nameMap);
		}

		return nameList;
	}
	
	/**
	 * <p>
	 * Converts a List of DOM4J Nodes into a List of processed NLAIdentity(s).
	 * Must indicate whether or not errors should cause processing to halt.
	 * </p>
	 * 
	 * @param nodes
	 *            A List of Nodes to process
	 * @param haltOnErrors
	 *            Flag if a single Node failing to process should halt
	 *            execution.
	 * @return List<NLAIdentity> A List of processed Identities
	 * @throws SRUException
	 *             If 'haltOnErrors' is set to TRUE and a Node fails to process.
	 */
	public static List<ExtNLAIdentity> convertAllNodesToIdentities(List<Node> nodes,
												boolean haltOnErrors) throws SRUException {
		List<ExtNLAIdentity> response = new ArrayList<ExtNLAIdentity>();
		// Sanity check
		if (nodes == null || nodes.isEmpty()) {
			return response;
		}
		// Process each Node in turn
		for (Node node : nodes) {
			try {
				ExtNLAIdentity newId = new ExtNLAIdentity(node);
				response.add(newId);

				// Only halt if requested
			} catch (SRUException ex) {
				log.error("Unable to process identity: ", ex);
				if (haltOnErrors) {
					throw ex;
				}
			}
		}
		return response;
	}
	
	public String getValueFromSingleNodeByName(Node parentNode, String nodeName){
		Node currentNode = parentNode.selectSingleNode(nodeName);
		return (currentNode != null)?currentNode.getText():null;
	}
	
}
