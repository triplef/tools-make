#
#   Instance/gswapp.make
#
#   Instance Makefile rules to build GNUstep web based applications.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Manuel Guesdon <mguesdon@sbuilders.com>
#   Based on application.make by Ovidiu Predescu <ovidiu@net-community.com>
#   Based on gswapp.make by Helge Hess, MDlink online service center GmbH.
#   Based on the original version by Scott Christley.
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# FIXME/TODO - this file has not been updated to use
# Instance/Shared/bundle.make because it is linking resources instead of
# copying them.


#
# The name of the application is in the GSWAPP_NAME variable.
# The list of languages the app is localized in are in xxx_LANGUAGES <==
# The list of application resource file are in xxx_RESOURCE_FILES
# The list of localized application resource file are in 
#  xxx_LOCALIZED_RESOURCE_FILES <==
# The list of application resource directories are in xxx_RESOURCE_DIRS
# The list of application web server resource directories are in 
#  xxx_WEBSERVER_RESOURCE_DIRS <==
# The list of localized application web server resource directories are in 
#  xxx_LOCALIZED_WEBSERVER_RESOURCE_DIRS
# where xxx is the application name <==

COMPONENTS = $($(GNUSTEP_INSTANCE)_COMPONENTS)
LANGUAGES = $($(GNUSTEP_INSTANCE)_LANGUAGES)
WEBSERVER_RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_FILES)
LOCALIZED_WEBSERVER_RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_LOCALIZED_WEBSERVER_RESOURCE_FILES)
WEBSERVER_RESOURCE_DIRS = $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_DIRS)
LOCALIZED_RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES)
RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_RESOURCE_FILES)
RESOURCE_DIRS = $($(GNUSTEP_INSTANCE)_RESOURCE_DIRS)


# Determine the application directory extension
ifeq ($(profile), yes)
  GSWAPP_EXTENSION = profile
else
  ifeq ($(debug), yes)
    GSWAPP_EXTENSION = debug
  else
    GSWAPP_EXTENSION = gswa
  endif
endif

GNUSTEP_GSWAPPS = $(GNUSTEP_INSTALLATION_DIR)/GSWApps

.PHONY: internal-gswapp-all_ \
        internal-gswapp-install_ \
        internal-gswapp-uninstall_ \
        gswapp-components \
        gswapp-webresource-dir \
        gswapp-webresource-files \
        gswapp-localized-webresource-files \
        gswapp-resource-dir \
        gswapp-resource-files \
        gswapp-localized-resource-files

# Libraries that go before the WO libraries
ALL_GSW_LIBS =								\
    $(shell $(WHICH_LIB_SCRIPT)						\
	$(ALL_LIB_DIRS)							\
	$(ADDITIONAL_GSW_LIBS) $(AUXILIARY_GSW_LIBS) $(GSW_LIBS)	\
	$(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS)			\
	$(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS)	\
        $(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)		\
	debug=$(debug) profile=$(profile) shared=$(shared)		\
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

GSWAPP_DIR_NAME = $(GNUSTEP_INSTANCE:=.$(GSWAPP_EXTENSION))
GSWAPP_DIR = $(GNUSTEP_BUILD_DIR)/$(GSWAPP_DIR_NAME)
GSWAPP_RESOURCE_DIRS =  $(foreach d, $(RESOURCE_DIRS), $(GSWAPP_DIR)/Resources/$(d))
GSWAPP_WEBSERVER_RESOURCE_DIRS =  $(foreach d, $(WEBSERVER_RESOURCE_DIRS), $(GSWAPP_DIR)/Resources/WebServer/$(d))
ifeq ($(strip $(LANGUAGES)),)
  LANGUAGES="English"
endif

# Support building NeXT applications
ifneq ($(FOUNDATION_LIB), apple)
GSWAPP_FILE_NAME = \
    $(GSWAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)
else
GSWAPP_FILE_NAME = $(GSWAPP_DIR_NAME)/$(GNUSTEP_INSTANCE)$(EXEEXT)
endif

GSWAPP_FILE = $(GNUSTEP_BUILD_DIR)/$(GSWAPP_FILE_NAME)

#
# Internal targets
#

$(GSWAPP_FILE): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ $(OBJ_FILES_TO_LINK)\
	      $(ALL_GSW_LIBS)$(END_ECHO)

ifneq ($(FOUNDATION_LIB), apple)
	$(ECHO_NOTHING)$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
	        >$(GSWAPP_DIR)/$(GNUSTEP_TARGET_LDIR)/library_paths.openapp$(END_ECHO)
endif

#
# Compilation targets
#
ifeq ($(FOUNDATION_LIB), apple)
internal-gswapp-all_:: \
	$(GNUSTEP_OBJ_DIR) $(GSWAPP_DIR) $(GSWAPP_FILE) \
	gswapp-components \
	gswapp-localized-webresource-files \
	gswapp-webresource-files \
	gswapp-localized-resource-files \
	gswapp-resource-files \
	$(GSWAPP_DIR)/$(GNUSTEP_INSTANCE).sh

$(GSWAPP_DIR):
	$(ECHO_CREATING)mkdir $@$(END_ECHO)
else

internal-gswapp-all_:: \
   $(GNUSTEP_OBJ_DIR) \
   $(GSWAPP_DIR)/$(GNUSTEP_TARGET_LDIR) $(GSWAPP_FILE) \
   gswapp-components \
   gswapp-localized-webresource-files \
   gswapp-webresource-files \
   gswapp-localized-resource-files \
   gswapp-resource-files \
   $(GSWAPP_DIR)/$(GNUSTEP_INSTANCE).sh

$(GSWAPP_DIR)/$(GNUSTEP_TARGET_LDIR):
	$(ECHO_CREATING)$(MKDIRS) $(GSWAPP_DIR)/$(GNUSTEP_TARGET_LDIR)$(END_ECHO)
endif

ifeq ($(GNUSTEP_INSTANCE)_GEN_SCRIPT,yes) #<==
$(GSWAPP_DIR)/$(GNUSTEP_INSTANCE).sh: $(GSWAPP_DIR)
	$(ECHO_CREATING)(echo "#!/bin/sh"; \
	  echo '# Automatically generated, do not edit!'; \
	  echo '$${GNUSTEP_HOST_LDIR}/$(GNUSTEP_INSTANCE) $$1 $$2 $$3 $$4 $$5 $$6 $$7 $$8') >$@$(END_ECHO)
	$(ECHO_NOTHING)chmod +x $@$(END_ECHO)
else
$(GSWAPP_DIR)/$(GNUSTEP_INSTANCE).sh:

endif

gswapp-components:: $(GSWAPP_DIR)/Resources
ifneq ($(strip $(COMPONENTS)),)
	@ echo "Linking components into the application wrapper..."; \
        cd $(GSWAPP_DIR)/Resources; \
        for component in $(COMPONENTS); do \
	  if [ -d ../../$$component ]; then \
	     $(LN_S) -f ../../$$component ./;\
	  fi; \
        done; \
	echo "Linking localized components into the application wrapper..."; \
        for l in $(LANGUAGES); do \
	  if [ -d ../../$$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(COMPONENTS); do \
	      if [ -d ../../../$$l.lproj/$$f ]; then \
	        $(LN_S) -f ../../../$$l.lproj/$$f .;\
	      fi;\
            done;\
	    cd ..; \
	  fi;\
	done
endif

# FIXME - this is behaving differently than in gswbundle.make !
# It's also not behaving consistently with xxx_RESOURCE_DIRS
gswapp-webresource-dir:: $(GSWAPP_WEBSERVER_RESOURCE_DIRS)
ifneq ($(strip $(WEBSERVER_RESOURCE_DIRS)),)
	@ echo "Linking webserver Resource Dirs into the application wrapper..."; \
        cd $(GSWAPP_DIR)/Resources; \
        for dir in $(WEBSERVER_RESOURCE_DIRS); do \
	  if [ -d ../../$$dir ]; then \
	     $(LN_S) -f ../../$$dir ./;\
	  fi; \
        done;
endif

$(GSWAPP_WEBSERVER_RESOURCE_DIRS):
	#@$(MKDIRS) $(GSWAPP_WEBSERVER_RESOURCE_DIRS)

gswapp-webresource-files:: $(GSWAPP_DIR)/Resources/WebServer \
                           gswapp-webresource-dir
ifneq ($(strip $(WEBSERVER_RESOURCE_FILES)),)
	@echo "Linking webserver resources into the application wrapper..."; \
        cd $(GSWAPP_DIR)/Resources/WebServer; \
        for ff in $(WEBSERVER_RESOURCE_FILES); do \
	  $(LN_S) -f ../../WebServerResources/$$ff .;\
        done
endif

gswapp-localized-webresource-files:: $(GSWAPP_DIR)/Resources/WebServer gswapp-webresource-dir
ifneq ($(strip $(LOCALIZED_WEBSERVER_RESOURCE_FILES)),)
	@ echo "Linking localized web resources into the application wrapper..."; \
	cd $(GSWAPP_DIR)/Resources/WebServer; \
	for l in $(LANGUAGES); do \
	  if [ -d ../../WebServerResources/$$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj;\
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
	      if [ -f ../../../WebServerResources/$$l.lproj/$$f ]; then \
	        if [ ! -r $$f ]; then \
	          $(LN_S) ../../../WebServerResources/$$l.lproj/$$f $$f;\
	        fi;\
	      fi;\
	    done;\
	    cd ..; \
	  else\
	   echo "Warning - WebServerResources/$$l.lproj not found - ignoring";\
	  fi;\
	done
endif

# This is not consistent with what other projects do ... so it can't stay
# this way.  Use COMPONENTS instead.
gswapp-resource-dir:: $(GSWAPP_RESOURCE_DIRS)
ifneq ($(strip $(RESOURCE_DIRS)),)
	@ echo "Linking Resource Dirs into the application wrapper..."; \
        cd $(GSWAPP_DIR)/Resources; \
        for dir in $(RESOURCE_DIRS); do \
	  if [ -d ../../$$dir ]; then \
	     $(LN_S) -f ../../$$dir ./;\
	  fi; \
        done;
endif

$(GSWAPP_RESOURCE_DIRS):
	#@$(MKDIRS) $(GSWAPP_RESOURCE_DIRS)

gswapp-resource-files:: $(GSWAPP_DIR)/Resources/Info-gnustep.plist \
                        gswapp-resource-dir
ifneq ($(strip $(RESOURCE_FILES)),)
	@ echo "Linking resources into the application wrapper..."; \
        cd $(GSWAPP_DIR)/Resources/; \
        for ff in $(RESOURCE_FILES); do \
	  echo $$ff; \
	  $(LN_S) -f ../../$$ff .;\
        done
endif

gswapp-localized-resource-files:: $(GSWAPP_DIR)/Resources \
                                  gswapp-resource-dir
ifneq ($(strip $(LOCALIZED_RESOURCE_FILES)),)
	@ echo "Linking localized resources into the application wrapper..."; \
        cd $(GSWAPP_DIR)/Resources; \
        for l in $(LANGUAGES); do \
	  if [ -d ../../$$l.lproj ]; then 
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
              if [ -f ../../../$$l.lproj/$$f ]; then \
	        echo $$l.lproj/$$ff; \
	        $(LN_S) -f ../../../$$l.lproj/$$f .;\
	      fi;\
	    done;\
	    cd ..; \
	  else \
	   echo "Warning - $$l.lproj not found - ignoring";\
	  fi;\
	done
endif

PRINCIPAL_CLASS = $(strip $($(GNUSTEP_INSTANCE)_PRINCIPAL_CLASS))

ifeq ($(PRINCIPAL_CLASS),)
  PRINCIPAL_CLASS = $(GNUSTEP_INSTANCE)
endif

HAS_GSWCOMPONENTS = $($(GNUSTEP_INSTANCE)_HAS_GSWCOMPONENTS)
GSWAPP_INFO_PLIST = $($(GNUSTEP_INSTANCE)_GSWAPP_INFO_PLIST)
MAIN_MODEL_FILE = $(strip $(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$($(GNUSTEP_INSTANCE)_MAIN_MODEL_FILE)))))

$(GSWAPP_DIR)/Resources/Info-gnustep.plist: $(GSWAPP_DIR)/Resources
	$(ECHO_CREATING)(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  if [ "$(HAS_GSWCOMPONENTS)" != "" ]; then \
	    echo "  HasGSWComponents = \"$(HAS_GSWCOMPONENTS)\";"; \
	  fi; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  if [ -r "$(GNUSTEP_INSTANCE)Info.plist" ]; then \
	    cat $(GNUSTEP_INSTANCE)Info.plist; \
	  fi; \
	  if [ "$(GSWAPP_INFO_PLIST)" != "" ]; then \
	    cat $(GSWAPP_INFO_PLIST); \
	  fi; \
	  echo "}") >$@$(END_ECHO)

$(GSWAPP_DIR)/Resources:
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

$(GSWAPP_DIR)/Resources/WebServer:
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

internal-gswapp-install_::
	$(ECHO_INSTALLING)$(MKINSTALLDIRS) $(GNUSTEP_GSWAPPS); \
	rm -rf $(GNUSTEP_GSWAPPS)/$(GSWAPP_DIR_NAME); \
	(cd $(GNUSTEP_BUILD_DIR); $(TAR) ch --exclude=CVS --to-stdout $(GSWAPP_DIR_NAME)) | (cd $(GNUSTEP_GSWAPPS); $(TAR) xf -)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) $(GNUSTEP_GSWAPPS)/$(GSWAPP_DIR_NAME)$(END_ECHO)
endif
ifeq ($(strip),yes)
	$(ECHO_STRIPPING)$(STRIP) $(GNUSTEP_GSWAPPS)/$(GSWAPP_FILE_NAME)$(END_ECHO)
endif

internal-gswapp-uninstall_::
	$(ECHO_UNINSTALLING)(cd $(GNUSTEP_GSWAPPS); rm -rf $(GSWAPP_DIR_NAME))$(END_ECHO)

include $(GNUSTEP_MAKEFILES)/Instance/Shared/strings.make
