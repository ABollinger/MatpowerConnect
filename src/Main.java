import org.nlogo.app.App;

public class Main {
	
	public static void main(final String[] argv) {
        App.main(argv);
        try {
            java.awt.EventQueue.invokeAndWait
                ( new Runnable()
                    { public void run() {
                        try {
                        	//App.app.open
                        	App.app().open
                              (argv[0]);
                        		
                        	
                        }
                        catch( java.io.IOException ex ) {
                          ex.printStackTrace();
                        }
                    } } );
        }
        catch(Exception ex) {
            ex.printStackTrace();
        }
    }

}
