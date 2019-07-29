package memorize;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Created by Александра on 15.04.2018.
 */
public abstract class DBManager {
    public Connection connection;

    public DBManager(Connection connection)
    {
        this.connection = connection;
    }

    public void close() {
        try {
            if (connection != null)
                connection.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
