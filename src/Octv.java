import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;

import org.nlogo.api.*;

import dk.ange.octave.OctaveEngine;
import dk.ange.octave.OctaveEngineFactory;
import dk.ange.octave.type.OctaveDouble;

public class Octv extends DefaultReporter {
	
	public static OctaveEngine octave = null;
	
	public Syntax getSyntax() {
        return Syntax.reporterSyntax(
            // new int[] {Syntax.TYPE_NUMBER}, Syntax.TYPE_NUMBER
        	new int[] {Syntax.NumberType()}, Syntax.NumberType()
        );
    }
	
	public Object report(Argument args[], Context context)
    	throws ExtensionException
    {
		octave = new OctaveEngineFactory().getScriptEngine();
		
		//this is what you're going to return
		//LogoList listfornetlogo = new LogoList();
		LogoListBuilder listfornetlogo = new LogoListBuilder();
		
		// set the Matpower variables
		String version = "2";

		
		try {
		 						 
			LogoList netlogonetwork = args[0].getList();

			Object basemvaobject = netlogonetwork.get(0);
			String basemvastring = basemvaobject.toString();
			
			basemvastring = basemvastring.replaceAll("\\[\\[", "\\[");
			basemvastring = basemvastring.replaceAll("\\]\\]", ";\\]");
			basemvastring = basemvastring.replaceAll("\\], \\[", "; ");
			basemvastring = basemvastring.replaceAll(", ", "\t");
			
			//System.out.println("base mva is " + basemvastring);
			

			Object busobject = netlogonetwork.get(1);
			String busstring = busobject.toString();
			
			busstring = busstring.replaceAll("\\[\\[", "\\[");
			busstring = busstring.replaceAll("\\]\\]", ";\\]");
			busstring = busstring.replaceAll("\\], \\[", "; ");
			busstring = busstring.replaceAll(", ", "\t");
			
			//System.out.println("bus list is " + busstring);
			
			
			Object genobject = netlogonetwork.get(2);
			String genstring = genobject.toString();
			
			genstring = genstring.replaceAll("\\[\\[", "\\[");
			genstring = genstring.replaceAll("\\]\\]", ";\\]");
			genstring = genstring.replaceAll("\\], \\[", "; ");
			genstring = genstring.replaceAll(", ", "\t");
			
			//System.out.println("gen list is " + genstring);
			
			
			Object branchobject = netlogonetwork.get(3);
			String branchstring = branchobject.toString();
			
			branchstring = branchstring.replaceAll("\\[\\[", "\\[");
			branchstring = branchstring.replaceAll("\\]\\]", ";\\]");
			branchstring = branchstring.replaceAll("\\], \\[", "; ");
			branchstring = branchstring.replaceAll(", ", "\t");
			
			//System.out.println("branch list is " + branchstring);
			
			
			//Object gencostobject = netlogonetwork.get(4);
			//String gencoststring = gencostobject.toString();
			
			//gencoststring = gencoststring.replaceAll("\\[\\[", "\\[");
			//gencoststring = gencoststring.replaceAll("\\]\\]", ";\\]");
			//gencoststring = gencoststring.replaceAll("\\], \\[", "; ");
			//gencoststring = gencoststring.replaceAll(", ", "\t");
			
			//System.out.println("gencost list is " + gencoststring);
			
			
			Object areaobject = netlogonetwork.get(4);
			String areastring = areaobject.toString();
			
			areastring = areastring.replaceAll("\\[\\[", "\\[");
			areastring = areastring.replaceAll("\\]\\]", ";\\]");
			areastring = areastring.replaceAll("\\], \\[", "; ");
			areastring = areastring.replaceAll(", ", "\t");
			
			//System.out.println("area list is " + areastring);
			
			// determine the analysis type:
			// 0 = regular load flow
			// 1 = n - 1 contingency
			// 2 = n - 2 contingency
			//Object analysistypeobject = netlogonetwork.get(6);
			//String analysistypestring = analysistypeobject.toString();
			
			String basemva = basemvastring;
			String bus = busstring;
			String gen = genstring;
			String branch = branchstring;
			//String gencost = gencoststring;
			String area = areastring;
			//String analysistype = analysistypestring;
			 
			 // add matpower to octave's path
			 //octave.eval("addpath(\"/home/andrewbollinger/matpower4.0b4\");");
			 //octave.eval("addpath(" + argv[1] + ");");
			 //octave.eval("addpath(\"/home/andrewbollinger/matpower4.0b4/t\");");
			 //octave.eval("addpath(argv[2]);");
			//octave.eval("addpath(genpath(\"matpower4.0b4\"));");
			octave.eval("addpath(genpath(\"mfiles\"));");
			 
			 // create some matrices in octave
			 octave.eval("bus = " + bus + ";");
			 octave.eval("baseMVA = " + basemva + ";");
			 octave.eval("version = " + version + ";");
			 octave.eval("gen = " + gen + ";");
			 octave.eval("branch = " + branch + ";");
			 //octave.eval("gencost = " + gencost);
			 octave.eval("area = " + area + ";");
			 //octave.eval("analysistype = " + analysistype);
			 
			 // create a struct from the matrices in octave.  this is the case to be evaluated.
			 octave.eval("mpc = struct('version', version, 'baseMVA', baseMVA, 'bus', bus, 'gen', gen, 'branch', branch, 'area', area);");
			 
			 // RUN CONTINGENCY ANALYSIS
			 octave.eval("PowerFlowWrapper;");
			 
			 // GET THE BRANCH DATA BACK 
			 octave.eval("powerflows = contingencyresults;");
			 octave.eval("[powerflowrows,powerflowcols] = size(powerflows);");
			 OctaveDouble powerflowrows = octave.get(OctaveDouble.class, "powerflowrows");
			 double powerflowrows2 = powerflowrows.get(1);
			 //System.out.println("powerflowrows2 is " + powerflowrows2);
			 
			 OctaveDouble powerflows = octave.get(OctaveDouble.class, "powerflows");
			 
			 //LogoList powerflowslist = new LogoList();
			 LogoListBuilder powerflowslist = new LogoListBuilder();
			 for(int i=1;i<=powerflowrows2;i++){
				 
				 //LogoList powerflowslist2 = new LogoList();
				 LogoListBuilder powerflowslist2 = new LogoListBuilder();
				 for(int j=1;j<=5;j++){
					 
					 //powerflowslist2.add(j,powerflows.get(i,j));
					 powerflowslist2.add(powerflows.get(i,j));
				 }
				 
				 //powerflowslist.add(i,powerflowslist2);
				 powerflowslist.add(powerflowslist2.toLogoList());
			 }
			 //System.out.println("powerflowslist is " + powerflowslist.toLogoList());
			 
			 // GET THE GENERATOR DATA BACK 
			 octave.eval("generatoroutputs = generatorresults;");
			 octave.eval("[generatorrows,generatorcols] = size(generatoroutputs);");
			 OctaveDouble generatorrows = octave.get(OctaveDouble.class, "generatorrows");
			 double generatorrows2 = generatorrows.get(1);
			 //System.out.println("generatorrows2 is " + generatorrows2);
			 
			 OctaveDouble generatoroutputs = octave.get(OctaveDouble.class, "generatoroutputs");
			 
			 //LogoList generatoroutputslist = new LogoList();
			 LogoListBuilder generatoroutputslist = new LogoListBuilder();
			 for(int i=1;i<=generatorrows2;i++){
				 
				 //LogoList generatoroutputslist2 = new LogoList();
				 LogoListBuilder generatoroutputslist2 = new LogoListBuilder();
				 for(int j=1;j<=2;j++){
					 
					 //generatoroutputslist2.add(j,generatoroutputs.get(i,j));
					 generatoroutputslist2.add(generatoroutputs.get(i,j));
				 }
				 //generatoroutputslist.add(i,generatoroutputslist2);
				 generatoroutputslist.add(generatoroutputslist2.toLogoList());
			 }
			 //System.out.println("generatoroutputslist is " + generatoroutputslist.toLogoList());
			 
			 //listfornetlogo.add(1,powerflowslist);
			 //listfornetlogo.add(2,generatoroutputslist);
			 listfornetlogo.add(powerflowslist.toLogoList());
			 listfornetlogo.add(generatoroutputslist.toLogoList());
			 
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
		 
		 // PASS THE POWER FLOWS BACK TO NETLOGO
		 //System.out.println("about to return something");
		 return listfornetlogo.toLogoList();
			 
    }			 
}	 
