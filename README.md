# Welcome to the PSS Allocations repo
Here, you will find a collection of source code and files that are useful for colleagues continuing the analytical work 

# Flow chart / graph for Variations Tool data sources
This flowchart describes the totality of data sources and modelling that are dependencies for the Variations Tool as it currently stands.

# Data Sources
- PLCM:
  - PLD
  - Drugs
  - Devices
- CCMDS


```mermaid

graph LR
    subgraph Data Extraction
        Ashley[Run SQL Neonatal CC] --> Neonatal_Critical_Care_Data
        Ashley[Run SQL Adult CC] --> Adult_Critical_Care_Data
        Daniel[Run SQL Physical Health] --> Physical_Health_Data
    end
    
    Physical_Health_Data --> Split_Data
    Split_Data --> Physical_Health_Overall
    Split_Data --> Cancer_Submodel
    Split_Data --> Cardiac_Submodel
    Split_Data --> Renal_Submodel
    
    Neonatal_Critical_Care_Data --> Preprocessing
    Adult_Critical_Care_Data --> Preprocessing
    Physical_Health_Overall --> Preprocessing
    Cancer_Submodel --> Preprocessing
    Cardiac_Submodel --> Preprocessing
    Renal_Submodel --> Preprocessing
    
    subgraph Modelling
        Ashley[R Script Neonatal CC] --> Neonatal_Model
        Ashley[R Script ACC Elective] --> ACC_Elective_Model
        Ashley[R Script ACC Non-Elective] --> ACC_NonElective_Model
        Sion[STATA Script Cancer] --> Cancer_Model
        Sion[STATA Script Cardiac] --> Cardiac_Model
        Sion[STATA Script Renal] --> Renal_Model
        Daniel[STATA Scripts Physical Health - Batches] --> Physical_Health_Model
    end
    
    Preprocessing --> Modelling
    
    Neonatal_Model --> Feedback_Loop
    ACC_Elective_Model --> Feedback_Loop
    ACC_NonElective_Model --> Feedback_Loop
    Cancer_Model --> Feedback_Loop
    Cardiac_Model --> Feedback_Loop
    Renal_Model --> Feedback_Loop
    Physical_Health_Model --> Feedback_Loop
    
    subgraph Feedback_Loop
        Feedback[Feedback from Experts/Commissioners] --> Update_Model[Yes] --> Improved_Model
        Improved_Model --> Save_Results
        Feedback[No] --> Save_Results
    end
    
    Save_Results --> Combine_Model_Outputs
    
    Combine_Model_Outputs --> Need_Weighted_Population
    Need_Weighted_Population --> Need_Indices
    
    Ashley[Extract Utilisation Data] --> Utilisation_Data
    Combine_Model_Outputs --> Need_Indices
    Need_Indices --> PSS_Tool
    Utilisation_Data --> PSS_Tool
    
    Donald[Calculate Avoidable Mortality] --> PSS_Tool
    
    PSS_Tool --> Share_Results
```

# Purpose and Audience
This work (at the time of publication) has three primary purposes, described below. These are the success criteria against which to assess the outputs. It Should be noted that there are several things which this modelling work is not intended to be (and hence is not a measure of its success), namely, it is not intended as a model of Provider or Site resource allocation, neither descriptively or normatively. This is a separate piece of work that regional and ICB colleagues will need to undertake using local intelligence, geography, transportation links, etc., in order to design the most appropriate way of organisation a population-based allocation of resources.



# Notes on the Modelling Procedure
