package org.example.config;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public final class HibernateUtil {
    private static final SessionFactory SESSION_FACTORY = buildSessionFactory();

    private HibernateUtil() { }

    private static SessionFactory buildSessionFactory() {
        try {
            return new Configuration().configure().buildSessionFactory();
        } catch (Exception exception) {
            throw new ExceptionInInitializerError("Could not create Hibernate SessionFactory: " + exception.getMessage());
        }
    }

    public static SessionFactory getSessionFactory() { return SESSION_FACTORY; }

    public static void shutdown() { SESSION_FACTORY.close(); }
}
