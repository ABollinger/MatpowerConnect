import org.nlogo.api.*;

public class MatpowerConnectExtension extends DefaultClassManager {
	
	public void load(PrimitiveManager primitiveManager) 
	{
        primitiveManager.addPrimitive( "octavetest" , new Octv() ) ;
    }

}
