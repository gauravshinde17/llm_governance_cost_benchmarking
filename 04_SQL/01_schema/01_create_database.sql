-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Infrastructure
-- File   : 01_create_database.sql
-- Purpose: Create core database with production-safe defaults
-- =====================================================

CREATE DATABASE IF NOT EXISTS llm_governance_fintech
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE llm_governance_fintech;