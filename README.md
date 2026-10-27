# Consentinel Consent Mode — Tag Manager template

A Google Tag Manager tag that bridges [Consentinel](https://consentinel.co)'s
consent state into Google Consent Mode for the tags Tag Manager manages.

## What it does

On the **Consent Initialization - All Pages** trigger it:

1. Sets the Consent Mode default — all seven consent types denied except
   `security_storage`, with `wait_for_update: 500` — the same default the
   Consentinel bundle sets.
2. Restores a returning visitor's stored choice from the `consentinel_v1`
   cookie, inside Tag Manager's sandbox.
3. Registers for in-page consent changes through
   `window.ConsentinelCloud.onConsentApplied`, so every accept, reject,
   save, withdraw or Do-Not-Sell action reaches Consent Mode.

It never loads the Consentinel bundle.

## Before you add it

**Consentinel Cloud must already be installed on the site as the first
synchronous script in `<head>`.** Get the snippet from your site's Embed tab
in the Consentinel dashboard, or connect a WordPress site through the
Consentinel plugin's Bridge. This tag does not install Consentinel; a tag
loaded by Tag Manager cannot be the first script on a page, and being first is
what Consentinel's blocking depends on.

## Setup

1. Add the template from the Community Template Gallery.
2. Create a tag from it. It has no fields.
3. Set the trigger to **Consent Initialization - All Pages**.
4. Publish the container.

## When the tag shows red in Preview

The tag fails on purpose when it cannot do its job, and the reason is in the
console and in Preview. Each reason has one fix:

| Message says | Cause | Fix |
|---|---|---|
| "…must be the first synchronous script…" | Consentinel is not on the page, or Tag Manager loaded before it. | Install the snippet, or move it above the Tag Manager snippet. |
| "…predates the version this tag needs…" | The site's Consentinel bundle was published before this API existed. | Republish the site from the Consentinel dashboard. |
| "…blocker is on this page but its Cloud API is not…" | Either the site runs the Consentinel plugin in local mode, or its Cloud bundle predates this tag's API. | WordPress: Connect the site to Cloud (Settings → Bridge). Otherwise: Republish the site from the Consentinel dashboard. |
| "…turned off in this site's Consentinel settings…" | Google Consent Mode signals are switched off for the site. | Turn them on in Customize → Behavior and republish, or remove this tag. |

## What to expect on a standard install

On a standard Consentinel install the Tag Manager container itself is held
until the visitor grants **marketing** consent, so nothing inside the
container — including a GA4 tag — runs before that. A visitor who grants
analytics only will not see GA4 fire through Tag Manager. That is the
enforcement working. (Locked website builders that render the container above
your own code, containers served from a custom domain, and a site whose
operator has set Tag Manager to never block are the exceptions;
Consentinel publishes its platform limits at
[consentinel.co/platforms](https://consentinel.co/platforms).)

## Settings that live in Consentinel, not here

Ads data redaction, URL passthrough and the Consent Mode switch itself are
configured in the Consentinel dashboard under Customize → Behavior. The
template does not duplicate them; a second writer would race the first.

The consent cookie name is fixed at `consentinel_v1`. A site with a custom
cookie name still receives every in-page change through the listener, but
the returning-visitor restore from the cookie is skipped.

## Not legal advice

This template passes a consent signal to Google's tags. Whether your site's
consent flow is adequate for your visitors and your jurisdictions is a
question for your own counsel.

## Source

The template's source, tests and the drift guards that keep it matched to the
Consentinel SDK live in Consentinel's private monorepo; this public
repository is the gallery's copy and is regenerated from it.
