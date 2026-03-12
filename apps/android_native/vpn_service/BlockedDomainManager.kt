package com.deenguard.android.vpn_service

import android.content.Context
import android.content.SharedPreferences

object BlockedDomainManager {
    private const val PREFS_NAME = "deenguard_blocked"
    private const val KEY_DOMAINS = "blocked_domains"
    
    private var prefs: SharedPreferences? = null
    private var blockedDomains: MutableSet<String> = mutableSetOf()
    
    fun init(context: Context) {
        prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        loadDomains()
    }
    
    private fun loadDomains() {
        prefs?.let {
            val domains = it.getStringSet(KEY_DOMAINS, emptySet())
            blockedDomains = domains?.toMutableSet() ?: mutableSetOf()
        }
    }
    
    fun isBlocked(domain: String): Boolean {
        val normalizedDomain = domain.lowercase().removePrefix("www.")
        return blockedDomains.any { blocked -> 
            normalizedDomain == blocked || normalizedDomain.endsWith(".$blocked")
        }
    }
    
    fun addDomain(domain: String) {
        val normalizedDomain = domain.lowercase().removePrefix("www.")
        blockedDomains.add(normalizedDomain)
        saveDomains()
    }
    
    fun removeDomain(domain: String) {
        val normalizedDomain = domain.lowercase().removePrefix("www.")
        blockedDomains.remove(normalizedDomain)
        saveDomains()
    }
    
    fun getAllDomains(): Set<String> {
        return blockedDomains.toSet()
    }
    
    fun updateDomains(domains: Set<String>) {
        blockedDomains = domains.map { it.lowercase().removePrefix("www.") }.toMutableSet()
        saveDomains()
    }
    
    private fun saveDomains() {
        prefs?.edit()?.putStringSet(KEY_DOMAINS, blockedDomains)?.apply()
    }
}
