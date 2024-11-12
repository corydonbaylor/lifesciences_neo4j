# lifesciences_neo4j

We are using the HCT116 dataset from the following [website](https://bioplex.hms.harvard.edu/interactions.php). We are going to construct a PPI network. You can find the cleaned versions of the data in the data folder in this repo. 

## Setting Up

Loading in the nodes:

```cypher
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
CREATE (:Protein {uniprotId: row.uniprotId})
```

Loading in the relationships:

```cypher
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
MATCH (p1:Protein {uniprotId: row.UniprotA})
MATCH (p2:Protein {uniprotId: row.UniprotB})
CREATE (p1)-[:INTERACTS_WITH {
  pW: toFloat(row.pW), 
  pNI: toFloat(row.pNI), 
  pInt: toFloat(row.pInt)
}]->(p2)
```

Fixing from character to int:

```cypher
MATCH ()-[r:INTERACTS_WITH]->()
SET r.pInt = toFloat(r.pInt)
```

Create projection:

```cypher
CALL gds.graph.project(
    'ppi-with-rel-prop',
    'Protein',
    {
        INTERACTS_WITH: {
            type: 'INTERACTS_WITH',
            properties: ['pInt']
        }
    }
)
YIELD graphName, nodeCount, relationshipCount
```

## Running Some Algos

**PageRank**

PageRank can identify influential nodes based on the structure of the network. It considers both the number and quality of links.

```cypher
CALL gds.pageRank.stream('ppi-with-rel-prop')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).uniprotId AS uniprotId, score AS pageRank
ORDER BY pageRank DESC
LIMIT 10
```

**Betweenness Centrality**

Betweenness centrality identifies nodes that act as bridges in the network, which can be crucial for information flow.

```cypher
CALL gds.betweenness.stream('ppi-with-rel-prop')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).uniprotId AS uniprotId, score AS betweennessCentrality
ORDER BY betweennessCentrality DESC
LIMIT 10
```

