package org.example.config;

import org.example.model.User;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public final class HibernateUtil {
    private static final SessionFactory SESSION_FACTORY = buildSessionFactory();

    private HibernateUtil() { }

    private static SessionFactory buildSessionFactory() {
        try {
            return new Configuration()
                    .addAnnotatedClass(User.class)
                    .setProperty("hibernate.connection.driver_class", "org.h2.Driver")
                    .setProperty("hibernate.connection.url", "jdbc:h2:~/credit-sacco;AUTO_SERVER=TRUE")
                    .setProperty("hibernate.connection.username", "sa")
                    .setProperty("hibernate.connection.password", "")
                    .setProperty("hibernate.dialect", "org.hibernate.dialect.H2Dialect")
                    .setProperty("hibernate.hbm2ddl.auto", "update")
                    .setProperty("hibernate.show_sql", "false")
                    .buildSessionFactory();
        } catch (Exception exception) {
            throw new ExceptionInInitializerError("Could not create Hibernate SessionFactory: " + exception.getMessage());
        }
    }

    public static SessionFactory getSessionFactory() { return SESSION_FACTORY; }

    public static void shutdown() { SESSION_FACTORY.close(); }
}
