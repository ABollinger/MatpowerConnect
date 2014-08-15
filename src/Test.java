import org.nlogo.api.*;

import dk.ange.octave.OctaveEngine;
import dk.ange.octave.OctaveEngineFactory;
import dk.ange.octave.type.OctaveDouble;

public class Test {
	
	public Test() {
		 OctaveEngine octave = new OctaveEngineFactory().getScriptEngine();
		 
		// TEST: GET THE VERSION OF OCTAVE
		 System.out.println("Octave version is " + octave.getVersion());
			
		// TEST: HAVE OCTAVE SAY HELLO
		octave.eval("disp('hello world from octave!');");
		
		LogoListBuilder listfornetlogo = new LogoListBuilder();
		
		try {
		 	
			String analysistype = "0";
			
			 octave.eval("analysistype = " + analysistype);
			 
			 octave.eval("addpath(genpath(\"mfiles\"));");
			 
			 // create a struct from the matrices in octave.  this is the case to be evaluated.
			 octave.eval("mpc = loadcase('case9');");
			 
			 // RUN CONTINGENCY ANALYSIS
			 //octave.eval("ContingencyAnalysis2");
			 octave.eval("PowerFlowWrapper");
			 
			 // GET THE BRANCH DATA BACK 
			 octave.eval("powerflows = contingencyresults");
			 octave.eval("[powerflowrows,powerflowcols] = size(powerflows)");
			 OctaveDouble powerflowrows = octave.get(OctaveDouble.class, "powerflowrows");
			 double powerflowrows2 = powerflowrows.get(1);
			 System.out.println("powerflowrows2 is " + powerflowrows2);
			 
			 OctaveDouble powerflows = octave.get(OctaveDouble.class, "powerflows");
			 
			 LogoListBuilder powerflowslist = new LogoListBuilder();
			 for(int i=1;i<=powerflowrows2;i++){
				 
				 LogoListBuilder powerflowslist2 = new LogoListBuilder();
				 
				 for(int j=1;j<=5;j++){
					 
					 powerflowslist2.add(powerflows.get(i,j));
				 }
				 
				 powerflowslist.add(powerflowslist2.toLogoList());
			 }
			 System.out.println("powerflowslist is " + powerflowslist.toLogoList());
			 
			 // GET THE GENERATOR DATA BACK 
			 octave.eval("generatoroutputs = generatorresults");
			 octave.eval("[generatorrows,generatorcols] = size(generatoroutputs)");
			 OctaveDouble generatorrows = octave.get(OctaveDouble.class, "generatorrows");
			 double generatorrows2 = generatorrows.get(1);
			 System.out.println("generatorrows2 is " + generatorrows2);
			 
			 OctaveDouble generatoroutputs = octave.get(OctaveDouble.class, "generatoroutputs");
			 
			 LogoListBuilder generatoroutputslist = new LogoListBuilder();
			 for(int i=1;i<=generatorrows2;i++){
				 
				 LogoListBuilder generatoroutputslist2 = new LogoListBuilder();
				 for(int j=1;j<=2;j++){
					 
					 generatoroutputslist2.add(generatoroutputs.get(i,j));
				 }
				 
				 generatoroutputslist.add(generatoroutputslist2.toLogoList());
			 }
			 System.out.println("generatoroutputslist is " + generatoroutputslist.toLogoList());
			 
			 listfornetlogo.add(powerflowslist.toLogoList());
			 listfornetlogo.add(generatoroutputslist.toLogoList());
			 System.out.println("list for netlogo is " + listfornetlogo.toLogoList());
			 
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
			 
		 // CLOSE OCTAVE
		 try {  
			octave.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		new Test();
	}
	
}
