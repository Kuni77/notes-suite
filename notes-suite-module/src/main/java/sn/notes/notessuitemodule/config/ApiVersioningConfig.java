package sn.notes.notessuitemodule.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class ApiVersioningConfig implements WebMvcConfigurer {
    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
        // Configuration pour supporter le versioning
        configurer.addPathPrefix("/api/v1",
                c -> c.getPackageName().contains("web.rest.v1"));
        configurer.addPathPrefix("/api/v2",
                c -> c.getPackageName().contains("web.rest.v2"));
    }
}
